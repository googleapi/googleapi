{
  Unit NativeXmlAppend

  This unit implements a method to add XML fragments to the end of an existing
  XML file that resides on disk. The file is never loaded completely into memory,
  the new data will be appended at the end.

  This unit requires NativeXml.

  Possible exceptions (apart from the regular ones for file access):

  'Reverse read past beginning of stream':
    The file provided in S is not an XML file or it is an XML file with not enough
    levels. The XML file should have in its last tag at least ALevel levels of
    elements. Literally this exception means that the algorithm went backwards
    through the complete file and arrived at the beginning, without finding a
    suitable position to insert the node data.

  'Level cannot be found'
    This exception will be raised when the last element does not contain enough
    levels, so the algorithm encounters an opening tag where it would expect a
    closing tag.
    Example:
    We try to add a node at level 3 in this XML file
    <Root>
      <Level1>
        <Level2>
        </Level2>
      </Level1>
      <Level1>    <-- This last node does not have a level2, so the algorithm
      </Level1>       does not know where to add the data of level 3 under level2
    </Root>

  See Example4 for an implementation

  Original Author: Nils Haeck M.Sc.
  Copyright (c) 2003-2009 Simdesign B.V.

  It is NOT allowed under ANY circumstances to publish or copy this code
  without accepting the license conditions in accompanying LICENSE.txt
  first!

  This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
  ANY KIND, either express or implied.

  Please visit http://www.simdesign.nl/xml.html for more information.
}
unit NativeXmlAppend;

interface

{$I NativeXml.inc}

uses
  Classes, SysUtils, Dialogs, NativeXml;

type
  ustring = UTF8String;

// With this routine we can add a single node (TXmlNode) to an existing XML file.
// The file will NOT be read in completely, the data will simply be appended at the
// end. In order to do this, the file is scanned from the end until the last node
// at ALevel levels deep is located.
// ALevel = 0 would add the new node at the very end. This is not wise, since XML
// does not allow more than one root node. Choose ALevel = 1 to add the new node
// at the first level under the root (default).
// <p>
// TIP: If you want to start with an empty (template) XmlDocument, make sure to
// set TsdXmlDocument.UseFullNodes to True before saving it. This ensures that
// the append function will work correctly on the root node.
// <p>
// NOTE 1: This method does not work for unicode files.
procedure XmlAppendToExistingFile(const AFilename: string; ANode: TXmlNode;
  ALevel: integer {$IFDEF D4UP}= 1{$ENDIF});

implementation

type
  // We need this class to get access to protected method WriteToString
  THackNode = class(TXmlNode);

  TTagType = record
    FClose: string;
    FStart: string;
  end;

const

  // Reversed tags, note: the record fields are also in reversed order. This
  // is because we read backwards
  cTagCount = 4;
  cTags: array[0..cTagCount - 1] of TTagType = (
    // The order is important here; the items are searched for in appearing order
    (FClose: '>]]'; FStart: '[ATADC[!<'), // CDATA
    (FClose: '>--'; FStart: '--!<'),      // Comment
    (FClose: '>?';  FStart: '?<'),        // <?{something}?>
    (FClose: '>';   FStart: '<')          // Any other
  );

function ScanBackwards(S: TStream): char;
begin
  if S.Position = 0 then
    raise Exception.Create('Reverse read past beginning of stream');
  S.Seek(-1, soFromCurrent);
  S.Read(Result, 1);
  S.Seek(-1, soFromCurrent);
end;

function ReverseReadCloseTag(S: TStream): integer;
// Try to read the type of close tag from S, in reversed order
var
  AIndex, i: integer;
  Found: boolean;
  Ch: char;
begin
  Result := cTagCount - 1;
  AIndex := 1;
  repeat
    Found := False;
    inc(AIndex);
    Ch := ScanBackwards(S);
    for i := cTagCount - 1 downto 0 do begin
      if length(cTags[i].FClose) >= AIndex then
        if cTags[i].FClose[AIndex] = Ch then begin
          Found := True;
          Result := i;
          break;
        end;
    end;
  until Found = False;
  // Increase position again because we read too far
  S.Seek(1, soFromCurrent);
end;

procedure ReverseReadFromStreamUntil(S: TStream; const ASearch: string;
  var AValue: string);
// Read the tag in reversed order. We are looking for the string in ASearch
// (in reversed order). AValue will contain the tag when done (in correct order).
var
  AIndex: integer;
  Ch: char;
begin
  AIndex := 1;
  AValue := '';
  while AIndex <= length(ASearch) do begin
    Ch := ScanBackwards(S);
    AValue := Ch + AValue;
    if ASearch[AIndex] = Ch then
      inc(AIndex)
    else
      AIndex := 1;
  end;
  AValue := copy(AValue, Length(ASearch) + 1, length(AValue));
end;

function XmlScanNodeFromEnd(S: TStream; ALevel: integer): integer;
// Scan the stream S from the end and find the end of node at level ALevel
var
  Ch: char;
  ATagIndex: integer;
  AValue: string;
begin
  S.Seek(0, soFromEnd);
  while ALevel > 0 do begin
    Ch := ScanBackwards(S);
    if Ch = '>' then begin
      // Determine tag type from closing tag
      ATagIndex := ReverseReadCloseTag(S);
      // Try to find the start
      ReverseReadFromStreamUntil(S, cTags[ATagIndex].FStart, AValue);
      // We found the start, now decide what to do. We only decrease
      // level if this is a closing tag. If it is an opening tag, we
      // should raise an exception
      if (ATagIndex = 3) then begin
        if (Length(AValue) > 0) and (AValue[1] = '/') then
          dec(ALevel)
        else
          raise Exception.Create('Level cannot be found');
      end;
    end;
  end;
  Result := S.Position;
end;

procedure StreamInsertString(S: TStream; APos: integer; Value: string);
// Insert Value into stream S at position APos. The stream S (if it is a disk
// file) should have write access!
var
  ASize: integer;
  M: TMemoryStream;
begin
  // Nothing to do if no value
  if Length(Value) = 0 then exit;

  S.Position := APos;
  ASize := S.Size - S.Position;
  // Create intermediate memory stream that holds the new ending
  M := TMemoryStream.Create;
  try
    // Create a copy into a memory stream that contains new insert + old last part
    M.SetSize(ASize + Length(Value));
    M.Write(Value[1], Length(Value));
    M.CopyFrom(S, ASize);
    // Now add this copy at the current position
    M.Position := 0;
    S.Position := APos;
    S.CopyFrom(M, M.Size);
  finally
    M.Free;
  end;
end;

procedure XmlAppendToExistingFile(const AFilename: string; ANode: TXmlNode;
  ALevel: integer);
// With this routine we can add a single node (TXmlNode) to an existing XML file.
// The file will NOT be read in completely, the data will simply be appended at the
// end. In order to do this, the file is scanned from the end until the last node
// at ALevel levels deep is located.
// ALevel = 0 would add the new node at the very end. This is not wise, since XML
// does not allow more than one root node. Choose ALevel = 1 to add the new node
// at the first level under the root (default).
var
  S: TStream;
  APos: integer;
  AInsert: ustring;
begin
  // Open the file with Read/Write access
  S := TFileStream.Create(AFilename, fmOpenReadWrite or fmShareDenyWrite);
  try
    // After a successful open, we can locate the correct end of node
    APos := XmlScanNodeFromEnd(S, ALevel);
    // Still no exceptions, this means we found a valid position.. now insert the
    // new node in here.
    AInsert := THackNode(ANode).WriteToString;
    // Now we happily insert the string into the opened stream at the right position
    StreamInsertString(S, APos, string(AInsert));
  finally
    // We're done, close the stream, this will save the modified filestream
    S.Free;
  end;
end;

end.

{
  Here should be a description
  -----
  Hotkey: Ctrl+F9
}
unit TestUserScript;
uses mteFunctions;

var
  patchFile, bow: IInterface;

function Initialize: integer;
begin
  bow := RecordByFormID(filebyname('ccbgssse025-advdsgs.esm'), strtoint('$06000802'), true);
  
  doubleIt(bow);
end;

function doubleIt(e:IInterface):integer;
var i:integer;
    kwda:IInterface;
begin
  kwda := ElementBySignature(e, 'KWDA');
  addmessage(inttostr(ElementCount(kwda)));
  for i:=0 to ElementCount(ElementBySignature(e, 'KWDA'))-1 do begin
    //addmessage(basename(ElementByIndex(kwda, i)));
    addmessage(name(ElementBySignature(ElementByIndex(kwda, i), 'KWDA')));
    //addmessage(PathName(ElementByIndex(kwda, i)));
  end;
end;

function process(e:IInterface):integer;
begin
  //result:=doubleIt(e);
end;

function Finalize: Integer;
begin
  
end;

end.

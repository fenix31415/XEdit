{
  Here should be a description
  -----
  Hotkey: Ctrl+F10
}
unit TestUserScript;
uses mteFunctions, uselesscore;

var
  patchFile: IInterface;
  mstrs:TStringList;

function Initialize: integer;
var tmp, efile:IInterface;
s:string;
i:integer;
begin
  //patchFile := FileSelect('Select a file for barrels:');
end;

procedure printAllRecords(e:IInterface, sig:string);
var recCont:IInterface;
    i:integer;
begin
  recCont:=ElementByPath(e, sig);
  for i:=0 to ElementCount(recCont)-1 do
    addmessage(geteditvalue(ElementByIndex(recCont, i)));
end;

function process(e:IInterface):integer;
var s:string;
    tmp,i:integer;
    item, recCont:IInterface;
begin
  //addmessage(inttohex(FixedFormID(e),8));
  //addmessage(inttohex(FormID(e),8));
  //addmessage(inttohex(GetLoadOrderFormID(e),8));
  
  addmessage(geev(ElementByIndex(ElementByPath(e, 'Conditions'), 3), 'CTDA - CTDA\Function'));
  
  {if not assigned(ElementBySignature(e, 'EITM')) then
    enchs := Add(e, 'EITM', false) // we know that it always adds but why not
  else enchs := ElementByPath(e, 'EITM');
  element := ElementByIndex(enchs, 0);
  SetEditValue(element, '06DAAA50');}
  
  //addmessage(booltostr(isPresentInFile(e, filebyname('2.esp'))));
end;

function Finalize: Integer;
begin
  
end;

end.

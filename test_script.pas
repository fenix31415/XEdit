{
  Here should be a description
  -----
  Hotkey: Ctrl+F10
}
unit TestUserScript;
uses uselessCore, mtefunctions;

var
  patchFile: IInterface;
  mstrs:TStringList;

function Initialize: integer;
var tmp, efile:IInterface;
s:string;
i:integer;
begin
{  mstrs := TStringList.Create;
  mstrs.Duplicates := dupIgnore;
  mstrs.Sorted := True;
  
  
  addmessage(name(tmp));
  
  ReportRequiredMasters(tmp, mstrs, true, true);
  addmessage(inttostr(mstrs.Count));
  for i:=0 to mstrs.Count-1 do addmessage('q'+mstrs[i]);}
  
  //patchFile := FileSelect('Select a file for barrels:');
end;

function process(e:IInterface):integer;
var s:string;
    tmp,i:integer;
    item, recCont:IInterface;
begin
  //addmessage(GetElementEditValues(e, 'EDID'));
  {recCont := ElementByPath(e, 'Items');
  for i:=0 to ElementCount(recCont)-1 do begin
    item := LinksTo(ElementByPath(ElementByIndex(recCont, i), 'CNTO - Item\Item'));
    addmessage(inttohex(GetNativeValue(item),8));
  end;}
  //addmessage(booltostr(isPresentInFile(e, filebyname('2.esp'))));
end;

function Finalize: Integer;
begin
  
end;

end.

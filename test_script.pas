{
  Here should be a description
  -----
  Hotkey: Ctrl+F10
}
unit TestUserScript;
uses mteFunctions;

var
  patchFile: IInterface;
  mstrs:TStringList;

function copyWithMasters(e: IInterface): IInterface;
var i: integer;
  mstr, curFile: IInterface;
begin
  curFile := GetFile(e);
  AddMasterIfMissing(patchFile, GetFileName(curFile));
  for i := 0 to MasterCount(curFile) - 1 do begin
    mstr := MasterByIndex(curFile, i);
    AddMasterIfMissing(patchFile, GetFileName(mstr));
  end;
  result := wbCopyElementToFile(e, patchFile, false, true);
  if MasterCount(patchFile) > 200 then begin
    addmessage('started cleaning ' + inttostr(MasterCount(patchFile)));
    CleanMasters(patchFile);
    addmessage('finished cleaning ' + inttostr(MasterCount(patchFile)));
  end;
end;

function Initialize: integer;
var tmp, efile:IInterface;
s:string;
i:integer;
begin
  efile := filebyname('ShumerNWa.esp');
  tmp:=RecordByFormID(efile, strtoint('$0A1F8489'), true);
  //addmessage(booltostr(isPresentInFile(tmp, efile)));
{  mstrs := TStringList.Create;
  mstrs.Duplicates := dupIgnore;
  mstrs.Sorted := True;
  
  
  addmessage(name(tmp));
  
  ReportRequiredMasters(tmp, mstrs, true, true);
  addmessage(inttostr(mstrs.Count));
  for i:=0 to mstrs.Count-1 do addmessage('q'+mstrs[i]);}
  
  //patchFile := FileSelect('Select a file for barrels:');
end;

function isPresentInFile(e,f:IInterface):boolean;
var r:IInterface;
begin
  if SameText(getfilename(getfile(e)), getfilename(f)) or HasMaster(f, getfilename(getfile(e))) then begin
    r:=RecordByFormID(f, LoadOrderFormIDtoFileFormID(f, GetLoadOrderFormID(e)), False);
    if assigned(r) then result := SameText(getfilename(getfile(r)), getfilename(f)) else result := false;
  end else result:=false;
end;

function process(e:IInterface):integer;
var s:string;
    tmp,i:integer;
begin
  //ReportRequiredMasters(e, mstrs, true, true);
  //addmessage(inttostr(mstrs.Count));
  //for i:=0 to mstrs.Count-1 do addmessage('q'+mstrs[i]);
  //s:=name(GetContainer(e));
  //addmessage(name(e));
  //addmessage(s);
  addmessage(booltostr(isPresentInFile(e, filebyname('ShumerNWa.esp'))));
end;

function Finalize: Integer;
begin
  
end;

end.

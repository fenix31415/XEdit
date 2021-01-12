{
  Here should be a description
  -----
  Hotkey: Ctrl+F7
}
unit UserScript;
uses mteFunctions;
var
  patchFile: IInterface;
  files: TStringList;

function fileByFormid(id: string): string;
var i: integer;
  n: string;
  curFile:IInterface;
begin
  n := copy(id,1,2);
  for i := 0 to FileCount - 1 do begin
    curFile := FileByIndex(i);
    if copy(name(curFile),2,2) = n then begin result := basename(curFile); exit; end;
  end; result := '';
end;

procedure handleMasters(curFile: IInterface);
var i:integer;
begin
  AddMasterIfMissing(patchFile, GetFileName(curFile));
  for i := 0 to MasterCount(curFile) - 1 do begin
    AddMasterIfMissing(patchFile, GetFileName(MasterByIndex(curFile, i)));
  end;
end;

function getFullFormId(shortId, filename: string):IInterface;
var fileRecord: IInterface;
  tmp: string;
begin
  fileRecord := FileByName(fileName);
  tmp := '$' + copy(name(fileRecord),2,2) + shortId;
  result := RecordByFormID(fileRecord, StrToInt(tmp), true);
end;

function Initialize: integer;
var s:string;
begin
  ScriptProcessElements := [etFile];
  files := TStringList.Create;
end;

function process(e:IInterface):integer;
begin
  files.AddObject(GetFileName(e), TObject(e));
end;

function Finalize: Integer;
var patchFile1: IInterface;
    tmpStr:string;
begin
  files.Sort;
  patchFile := FileSelect('Select a file for barrels:');
  if not assigned(patchFile) then begin
    addmessage('no file selected, exiting..');
    result := 1;
    exit;
  end;
  
  /// stub for checking attendance
  AddMasterIfMissing(patchFile, 'Skyrim.esm');
  AddMasterIfMissing(patchFile, 'Update.esm');
  AddMasterIfMissing(patchFile, 'Dawnguard.esm');
  AddMasterIfMissing(patchFile, 'HearthFires.esm');
  AddMasterIfMissing(patchFile, 'Dragonborn.esm');
  
//patchFile1 := FileSelect('Select a file for laterns:');
  
  /// barrels
  changePro('CELL,WRLD', '0001E3A3', '65C406', 'LegacyoftheDragonborn.esm');
  
  /// Lanterns
  changePro('CELL,WRLD', '000318EC', '0111C2', 'Chesko_WearableLantern.esp');
  
  /// SaltPile
  changePro('COBJ', '00034CDF', '01CCA101', 'Complete Alchemy & Cooking Overhaul.esp');
  
  /// BOX
  changeBox();
  
  CleanMasters(patchFile);
  files.Free;
end;

procedure changePro(group, fromFullId, toShortName, toFilename: string);
begin
  //change(group, fromFullId, getFullNameToChange(toFilename, toShortName), toFilename);
  change(group, fromFullId, toShortName, copy(name(filebyname(toFilename)),2,2), toFilename);
  CleanMasters(patchFile);
end;

procedure changeBox();
var
  fromChange, toChange: TStringList;
  i:integer;
  tmpStr, prefix, filename:string;
  eFile: IInterface;
begin
  filename := name(filebyname('AHZLootableCratesSE.esp'));
  prefix := copy(filename,2,2)+copy(filename,5,3);
  eFile := filebyname('AHZLootableCratesSE.esp');

  fromChange:= TStringList.create;
  toChange:= TStringList.create;
  fromChange.Delimiter := ',';
  toChange.Delimiter := ',';
  fromChange.DelimitedText :=
  '0007A603,0007A605,0007A609,0007A60B,0007A60D,0007A610,0007A617,0007A619,000C2103,000C2104,'
  '000C2C05,000C2C13,000C2C15,000C2C16,000C2C17,000C2C1A,000C2C1B,000C2C1C,000C2C1D,000C2C1E,'
  '000D5712,000D5713,000D5714,000D5715,000E8E76,000E8E79,000E8E7E,000E8E7F,000F2458,000F2459,'
  '000F48CE,000F7299,0402979B,0403A11B,0403A11E,0403A11F,0403A120';
  
  toChange.DelimitedText :=
  'A91,A92,A93,A94,A95,A96,A97,A98,A99,A9A,'
  'A9B,A9C,A9D,A9E,A9F,AA0,AA1,AA2,AA3,AA4,'
  'AA9,AAA,AAB,AAC,AAF,AB0,AB1,AB2,AB3,AB4,'
  'AB5,AB6,ABC,ABD,ABE,ABF,AC0';
  
  
  for i := 0 to fromChange.Count - 1 do begin
    //tmpStr := name(RecordByFormID(eFile, strtoint(prefix+toChange[i]), true));
    change('CELL,WRLD', fromChange[i], toChange[i], prefix, 'AHZLootableCratesSE.esp');
  end;
end;

function shouldI(name: string):boolean;
var i: integer;
begin
  result := files.Find(name, i);
end;

procedure change(group, fromFullId, toShortName, prefix, toFilename: string);
var fromRecord: IInterface;
begin
  AddMasterIfMissing(patchFile, toFilename);
  fromRecord := getFullFormId(copy(fromFullId, 3, 6), fileByFormid(fromFullId));
  changeItAll(fromRecord, toShortName, prefix, toFilename, group);
end;

function copyWithMasters(e: IInterface): IInterface;
var i: integer;
  mstr, curFile: IInterface;
  mstrs:TStringList;
begin
  //handleMasters(GetFile(e));
  mstrs := TStringList.Create;
  mstrs.Duplicates := dupIgnore;
  mstrs.Sorted := True;
  
  AddMasterIfMissing(patchFile, getfilename(GetFile(MasterOrSelf(e))));
  ReportRequiredMasters(e, mstrs, true, true);
  for i:=0 to mstrs.Count-1 do begin
    AddMasterIfMissing(patchFile, mstrs[i]);
  end;
  result := wbCopyElementToFile(e, patchFile, false, true);
end;

/// r already winning
function normCopy(r:IInterface): IInterface;  // (no)
var parent, grandParent: IInterface;
  tmp2, tmp1:cardinal;
    contName:string;
    ttmp:integer;
begin
  parent := ChildrenOf(GetContainer(r));
  //addmessage('me:'+fullpath(r));
  
  contName := name(GetContainer(parent));
  if ContainsText(contName,'GRUP World Children of ') or ContainsText(contName,'GRUP Exterior Cell Sub-Block ') then begin
    grandParent := ChildrenOf(GetContainer(parent));
    //addmessage('grandParent:'+fullpath(grandParent));
    copyWithMasters(WinningOverride(grandParent));
  end;
  //addmessage('parent:'+fullpath(parent));
  copyWithMasters(WinningOverride(parent));
  
  result := copyWithMasters(r);
end;

function isRecordFrom(rec: IInterface; from: string): boolean;
begin
  result := ContainsText(fullpath(rec), 'GRUP Top "' + from + '"');
end;

function isInGroup(rec:IInterface; group:string):boolean;
var groups: TStringList;
    i:integer;
begin
  groups:= TStringList.create;
  groups.Delimiter := ',';
  groups.DelimitedText:=group;
  result := false;
  for i:=0 to groups.Count-1 do
    result := result or isRecordFrom(rec, groups[i]);
end;

function isPresentInFile(f, e:IInterface):boolean;
var r:IInterface;
begin
  if SameText(getfilename(getfile(e)), getfilename(f)) or HasMaster(f, getfilename(getfile(e))) then begin
    r:=RecordByFormID(f, LoadOrderFormIDtoFileFormID(f, GetLoadOrderFormID(e)), False);
    if assigned(r) then result := SameText(getfilename(getfile(r)), getfilename(f)) else result := false;
  end else result:=false;
end;

function isRandom(toNameShort:string):boolean;
begin
  result := SameText(toNameShort,'65C406');
end;

function getFullNameToChange(filename, toChange, prefix:string):string;
var eFile: IInterface;
    toNameShort:string;
begin
  if isRandom(toChange) then begin
    case random(3) of
      0 : toChange := '65C405';
      1 : toChange := '65C404';
    end;
  end;
  eFile := filebyname(filename);
  prefix := '$' + prefix;
  result := name(RecordByFormID(eFile, strtoint(prefix+toChange), true));
end;

procedure changeName(r:IInterface; baddd_toStr: string);
begin
  SetEditValue(r, baddd_toStr);
end;

procedure normChange(fromRecord, win:IInterface; toName:string); // (no) but better
var r:IInterface;
    id:integer;
begin
  if isInGroup(win, 'CELL,WRLD') then begin
    if not SameText(GetEditValue(ElementBySignature(win, 'NAME')), toName) then begin  
      r := normCopy(win);
      changeName(ElementBySignature(r, 'NAME'), toName);
    end;
  end else if isInGroup(win, 'COBJ') then begin
    r := normCopy(win);
    /// false seems ref removed
    if not CompareExchangeFormID(r, GetLoadOrderFormID(fromRecord), strtoint('$'+toName)) then /// toName='01CCA101'
      remove(r);
  end;
end;

procedure changeItAll(fromRecord: IInterface; toNameShort, prefix, toFileName, group: string);
var
  i: integer;
  r, cur, win: IInterface;
  toName, toChange:string;
begin
  if SameText(toNameShort, '01CCA101') then toName := toNameShort else
  if not isRandom(toNameShort) then toName := getFullNameToChange(toFileName, toNameShort, prefix);
  
  for i := ReferencedByCount(fromRecord)-1 downto 0 do begin
    cur := ReferencedByIndex(fromRecord, i);
    if not isInGroup(cur, group) then continue; // if record is not CELL or WRLD or staff
    if not shouldI(GetFileName(getfile(cur))) then continue;  // if record is not in dedicated file
    
    // 65C404 or 65C405 or (65C406)
    
    win := WinningOverride(cur);
    if not SameText(GetEditValue(ElementBySignature(win, 'NAME')), GetEditValue(ElementBySignature(cur, 'NAME'))) then continue;
    
    if isRandom(toNameShort) then toName := getFullNameToChange(toFileName, toNameShort, prefix);
    normChange(fromRecord, win, toName);
  end;
end;

end.

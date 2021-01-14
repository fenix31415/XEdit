{
  Here should be a description
  -----
  Hotkey: Ctrl+F9
}
unit DoubleIT;
uses mteFunctions, uselessCore;

const SOURCE_FILE_NAME = 'CBOS.esp';

var
  sourcePrefix:string;

function Initialize: integer;
begin
  ScriptProcessElements := [etFile];
  files := TStringList.Create;
  sourcePrefix := getPrefixByFileName(SOURCE_FILE_NAME);
end;

function process(e:IInterface):integer;
begin
  files.AddObject(GetFileName(e), TObject(e));
end;

function Finalize: Integer;
begin
  files.Sort;
  patchFile := FileSelect('Select a file for bow-doubling:');
  if not assigned(patchFile) then begin
    addmessage('no file selected, exiting..');
    result := 1;
    exit;
  end;
  
  AddMasterIfMissing(patchFile, 'Skyrim.esm');
  AddMasterIfMissing(patchFile, 'Update.esm');
  AddMasterIfMissing(patchFile, 'Dawnguard.esm');
  AddMasterIfMissing(patchFile, 'HearthFires.esm');
  AddMasterIfMissing(patchFile, 'Dragonborn.esm');
  
  main();
  
  CleanMasters(patchFile);
  files.Free;
end;

procedure main();
var fromRecord, cur, win: IInterface;
    i:integer;
begin
  fromRecord := RecordByHexFormID('0001E715');
  for i := ReferencedByCount(fromRecord)-1 downto 0 do begin
    cur := ReferencedByIndex(fromRecord, i);
    if not isInGroup(cur, 'WEAP') then continue; // if record is not WEAP
    
    if not shouldI(GetFileName(getfile(cur))) then continue;  // if record is not in dedicated file
    
    win := WinningOverride(cur);
    if checkETIM(win) then continue; // has enchants
    
    // is already modified
    if StrEndsWith(GetEditValue(ElementBySignature(win, 'FULL')), 'Лёгкий)') then continue;
    if StrEndsWith(GetEditValue(ElementBySignature(win, 'FULL')), 'Легкий)') then continue;
    if StrEndsWith(GetEditValue(ElementBySignature(win, 'FULL')), 'Тяжелый)') then continue;
    if StrEndsWith(GetEditValue(ElementBySignature(win, 'FULL')), 'Тяжёлый)') then continue;
    
    dodoubleIt(win);
  end;
end;

function checkETIM(e:IInterface): boolean;
begin
  result:=assigned(ElementBySignature(e, 'EITM'));
end;

procedure addSuffixToName(el:IInterface; suff:string);
var toStr:string;
begin
  toStr:=GetEditValue(el) + suff;
  SetEditValue(el, toStr);
end;

procedure changeIntValueBy(el:IInterface; delta:integer);
var val:integer;
begin
  val:=strtoint(GetEditValue(el)) + delta;
  SetEditValue(el, inttostr(val));
end;

procedure changeFloatValueBy(el:IInterface; delta:float);
var val:float;
begin
  val:=strtofloat(GetEditValue(el)) + delta;
  SetEditValue(el, floattostr(val));
end;

function decreaseAndNormalize(val, x:float):float;
begin
  val := val - x * val;
  val := roundto(val, -3);
  val := val * 100;
  val := floor(val);
  val := val / 100;
  result := val;
end;

procedure changeScaled(el:IInterface; x:float);
var val:float;
begin
  val := strtofloat(GetEditValue(el));
  val := decreaseAndNormalize(val, x);
  SetEditValue(el, floattostr(val));
end;

procedure changeData(e:IInterface);
begin
  addSuffixToName(ElementBySignature(e, 'FULL'), ' (Лёгкий)');
  changeIntValueBy(ElementByIndex(ElementBySignature(e, 'DATA'), 2), -2);
  changeScaled(ElementByIndex(ElementBySignature(e, 'DNAM'), 2), RandomRange(0, 100 + 1) / 1000); // speed
  SetEditValue(ElementByIndex(ElementBySignature(e, 'DNAM'), 26), floattostr(0.1)); // stagger
end;

procedure addEnchant(e:IInterface);
var element, enchs:IInterface;
    enchId:string;
begin
  if not assigned(ElementBySignature(e, 'EITM')) then
    enchs := Add(e, 'EITM', true) // we know that it always adds but why not
  else enchs := ElementByPath(e, 'EITM');
  enchId := sourcePrefix + inttohex(RandomRange($DAAA50,$DAAA56+1),6);
  SetEditValue(enchs, name(RecordByHexFormID(enchId)));
end;

procedure changeData_heavy(e:IInterface);
var newKywd:IInterface;
begin
  addSuffixToName(ElementBySignature(e, 'FULL'), ' (Тяжёлый)');
  addEnchant(e);
  newKywd := ElementAssign(ElementByPath(e, 'KWDA'), HighInteger, Nil, false);
  SetEditValue(newKywd, 'MagicDisallowEnchanting [KYWD:000C27BD]'); // without check
  changeIntValueBy(ElementByIndex(ElementBySignature(e, 'DATA'), 0), 10);
  changeFloatValueBy(ElementByIndex(ElementBySignature(e, 'DATA'), 1), 1);  // weight
  changeScaled(ElementByIndex(ElementBySignature(e, 'DNAM'), 2), RandomRange(400, 600 + 1) / 1000); // speed
end;

function findCraft(e:IInterface):IInterface;
var i:integer;
    cur, craft:IInterface;
begin
  for i := ReferencedByCount(e)-1 downto 0 do begin
    cur := ReferencedByIndex(e, i);
    if not SameText(signature(cur), 'COBJ') then continue;
    cur := winningoverride(cur);
    craft := ElementBySignature(cur, 'CNAM');
    if GetNativeValue(craft) <> FormID(e) then continue;
    // now seems we found it
    result:=cur;
    break; // assume theres only 1 craft satisfying
  end;
end;

function addItemToCraft(craftItems: IInterface; whatToAddId: string; amount: integer): IInterface;
var newItem:IInterface;
begin
  newItem := ElementAssign(craftItems, HighInteger, nil, false);
  result:=addItemToCraft_(craftItems, newItem, whatToAddId, amount);
end;

function addItemToCraft_(craftItems, newItem: IInterface; whatToAddId: string; amount: integer): IInterface;
begin
  SetElementEditValues(newItem, 'CNTO - Item\Item', whatToAddId);
  SetElementEditValues(newItem, 'CNTO - Item\Count', amount);
  Result := newItem;
end;

procedure changeCraft(craft:IInterface);
var craftItems,item,f:IInterface;
    i:integer;
    s,id:string;
begin
  craftItems := ElementByPath(craft, 'Items');
  addItemToCraft(craftItems, sourcePrefix + 'DA072E', 1);
  addItemToCraft(craftItems, sourcePrefix + 'DA0731', 2);
  
  id := sourcePrefix+'002327';
  
  f := FileByLoadOrder(StrToInt('$' + Copy(id, 1, 2)));
  addmessage('f='+name(f));
  s := name(RecordByFormID(f, StrToInt('$' + id), true));
  addmessage('s=' + s);
  
  //s:=name(RecordByHexFormID(id));
  addmessage('hej:' + sourcePrefix+'002327');
  seev(craft, 'BNAM', s);
end;

procedure changeCraft_heavy(craft, bow, bow_heavy:IInterface);
var craftItems,item, conditions, element:IInterface;
    i:integer;
begin
  Remove(ElementByPath(craft, 'Items'));
  craftItems := Add(craft, 'Items', true);
  addItemToCraft_(craftItems, ElementByIndex(craftItems, 0), '0000000F', randomrange(500,2500+1));
  addItemToCraft(craftItems, inttohex(GetLoadOrderFormID(bow),8), 1);
  addItemToCraft(craftItems, sourcePrefix + 'DA072E', 1);
  
  conditions := ElementByPath(craft, 'Conditions');
  if not assigned(conditions) then begin
    conditions := Add(craft, 'Conditions', True);
    element := ElementByIndex(conditions, 0);
  end else begin
    element := ElementAssign(conditions, HighInteger, nil, False);
  end;
  seev(element, 'CTDA - CTDA\Type', '10000000'); // ==
  seev(element, 'CTDA - CTDA\Comparison Value - Float', floattostr(1));
  seev(element, 'CTDA - CTDA\Function', 'HasPerk');
  seev(element, 'CTDA - CTDA\Perk', name(RecordByHexFormID(sourcePrefix+'DAFBC1')));
  
  element := ElementAssign(conditions, HighInteger, nil, False);
  seev(element, 'CTDA - CTDA\Type', '11000000'); // >=
  seev(element, 'CTDA - CTDA\Comparison Value - Float', floattostr(1));
  seev(element, 'CTDA - CTDA\Function', 'GetItemCount');
  seev(element, 'CTDA - CTDA\Inventory Object', name(bow));
  seev(craft, 'CNAM', name(bow_heavy));
  seev(craft, 'BNAM', name(RecordByHexFormID(sourcePrefix+'000D66')));
end;

procedure changeEdid(rec:IInterface);
var edid:string;
begin
  edid:=GetElementEditValues(rec, 'EDID');
  edid:=edid+'_heavy';
  SetElementEditValues(rec, 'EDID', edid);
end;

/// e is winning
function dodoubleIt(e:IInterface):integer;
var craft, bow_heavy:IInterface;
begin
  craft := findCraft(e);
  if not assigned(craft) then exit;
  AddMasterIfMissing(patchFile, SOURCE_FILE_NAME);
  AddMasterIfMissing(patchFile, getfilename(getfile(e)));
  AddMasterIfMissing(patchFile, getfilename(getfile(MasterOrSelf(e))));
  bow_heavy := normCopyWithPrefix(e, '', '', '_heavy');
  changeData_heavy(bow_heavy);
  changeData(normCopy(e));
  changeCraft_heavy(normCopyWithPrefix(craft, '', '', '_heavy'), e, bow_heavy);
  changeCraft(normCopy(craft));
end;

end.

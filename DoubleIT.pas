{
  Here should be a description
  -----
  Hotkey: Ctrl+F9
}
unit TestUserScript;
uses mteFunctions, uselessCore;

var
  bow: IInterface;

function Initialize: integer;
begin
  //bow := RecordByFormID(filebyname('ccbgssse025-advdsgs.esm'), strtoint('$06000802'), true);
  
  //doubleIt(bow);
end;

procedure doToKWD(e:IInterface, kwd:string);
var i:integer;
    kwda, cur:IInterface;
begin
  kwda := ElementBySignature(e, kwd);
  addmessage(inttostr(ElementCount(kwda)));
  for i:=0 to ElementCount(kwda)-1 do begin
    cur:=ElementByIndex(kwda, i);
    addmessage(GetEditValue(cur));
  end;
end;

function checkETIM(e:IInterface): boolean;
begin
  result:=assigned(ElementBySignature(e, 'EITM'));
end;

procedure changeName(el:IInterface; suff:string);
var toStr:string;
begin
  toStr:=GetEditValue(el) + suff;
  SetEditValue(el, toStr);
end;

procedure changeDamage(el:IInterface; delta: integer);
var val:integer;
begin
  val:=strtoint(GetEditValue(el)) + delta;
  SetEditValue(el, inttostr(val));
end;

procedure changeSpeed(el:IInterface);
var val, x:float;
begin
  val:=strtofloat(GetEditValue(el));
  x:=RandomRange(0, 100 + 1) / 1000;
  val := val - x * val;
  val := roundto(val, -3);
  val := val * 100;
  val := floor(val);
  val := val / 100;
  SetEditValue(el, floattostr(val));
end;

procedure changeStagger(el:IInterface);
var val:integer;
begin
  SetEditValue(el, floattostr(0.1));
end;

procedure changeData(e:IInterface);
begin
  changeName(ElementBySignature(e, 'FULL'), ' (À∏„ÍËÈ)');
  changeDamage(ElementByIndex(ElementBySignature(e, 'DATA'), 2), -2);
  changeSpeed(ElementByIndex(ElementBySignature(e, 'DNAM'), 2));
  changeStagger(ElementByIndex(ElementBySignature(e, 'DNAM'), 26));
end;

function copyRec(e:IInterface):IInterface;
var i:integer;
    cur, rec:IInterface;
begin
  for i := ReferencedByCount(e)-1 downto 0 do begin
    cur := ReferencedByIndex(e, i);
    if not SameText(signature(cur), 'COBJ') then continue;
    cur := winningoverride(cur);
    rec := ElementBySignature(cur, 'CNAM');
    if GetNativeValue(rec) <> FormID(e) then continue;
    // now seems we found it
    result:=normCopy(cur);
    break; // assume theres only 1 rec satisfying
  end;
end;

/// stolen from greatscript
function recordByShortId(shortId, filename: string):IInterface;
var fileRecord: IInterface;
  tmp: string;
begin
  fileRecord := FileByName(fileName);
  tmp := '$' + copy(name(fileRecord),2,2) + shortId;
  result := RecordByFormID(fileRecord, StrToInt(tmp), true);
end;

procedure changeCraft(craft:IInterface);
const STRANGE_NUMBERR = $02000000; // dont ask how
var recCont,cur,item, stringer:IInterface;
    i:integer;
begin
  recCont := ElementByPath(craft, 'Items');
  item := ElementAssign(recCont, HighInteger, nil, False);
  stringer := recordByShortId('DA072E', 'CBOS.esp');
  senv(item, 'CNTO\Item', $DA072E + STRANGE_NUMBERR); // dont ask me why
  seev(item, 'CNTO\Count', 1);
  item := ElementAssign(recCont, HighInteger, nil, False);
  senv(item, 'CNTO\Item', $DA0731 + STRANGE_NUMBERR); // dont ask me why
  seev(item, 'CNTO\Count', 2);
  seev(craft, 'BNAM', 'WIFletching [KYWD:'+copy(name(filebyname('CBOS.esp')),2,2)+'002327]');
  {recCont := ElementBySignature(craft, 'BNAM');
  for i:=0 to ElementCount(recCont)-1 do begin
    item := LinksTo(ElementByPath(ElementByIndex(recCont, i), 'CNTO - Item\Item'));
    addmessage(name(item));
  end;}
end;

procedure changeEdid(rec:IInterface);
var edid:string;
begin
  edid:=GetElementEditValues(rec, 'EDID');
  edid:=edid+'_heavy';
  SetElementEditValues(rec, 'EDID', edid);
end;

/// e is winning
function doubleIt(e:IInterface):integer;
var i:integer;
    cur, r, rec:IInterface;
begin
  if checkETIM(e) then exit; // has enchants
  patchFile := FileSelect('where double');
  AddMasterIfMissing(patchFile, 'CBOS.esp');
  AddMasterIfMissing(patchFile, getfilename(getfile(e)));
  AddMasterIfMissing(patchFile, getfilename(getfile(MasterOrSelf(e))));
  if not assigned(patchFile) then begin
    addmessage('no file selected, exiting..(no)');
    exit;
  end;
  
  //r:=normCopy(e);
  addmessage('q');
  r:=normCopyWithPrefix(e, '', '', '_heavy');
  addmessage('w');
  r:=normCopy(e);
  
  addmessage('2');
  changeData(r);
  
  addmessage('3');
  rec:=copyRec(e);
  if not assigned(rec) then begin addmessage('!#$!@&!@#$%!^@&% cant copy rec'); exit; end;
  
  changeCraft(rec);
  
end;

function process(e:IInterface):integer;
var tmp,cur,kwda, rec,rec_copy:IInterface;
    i:integer;
begin
  {patchFile := FileSelect('where double');
  if not assigned(patchFile) then begin
    addmessage('no file selected, exiting..(no)');
    exit;
  end;}
  result:=doubleIt(e);
  //changeData(e);
  //changeCraft(e);
  
  {kwda := ElementBySignature(e, 'DNAM');
  for i:=0 to ElementCount(kwda)-1 do begin
    cur:=ElementByIndex(kwda, i);
    addmessage(inttostr(i)+') '+name(cur)+': '+GetEditValue(cur));
  end;}
end;

function Finalize: Integer;
begin
  
end;

end.

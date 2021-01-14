{
  Here should be a description
  -----
  Hotkey: Ctrl+F10
}
unit UselessCore;

interface

var
  patchFile: IInterface;
  files:TStringList;


/// return true if name is in the files
function shouldI(name: string):boolean;

/// checks if rec in one of the group(s)
function isInGroup(rec:IInterface; group:string):boolean;

/// returns file prefix bi it's name
function getPrefixByFileName(name:string):string;

/// copy e with parent, grandparent and their masters
function normCopy(r:IInterface): IInterface;  // (no)

/// a prefix-version of normCopy
function normCopyWithPrefix(r:IInterface; aPrefixRemove, aPrefix, aSuffix: string): IInterface;  // (no)

implementation

uses mteFunctions;

function shouldI(name: string):boolean;
var i: integer;
begin
  result := files.Find(name, i);
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

function isRecordFrom(rec: IInterface; from: string): boolean;
begin
  result := ContainsText(fullpath(rec), 'GRUP Top "' + from + '"');
end;

function getPrefixByFileName(filename:string):string;
var f:IInterface;
begin
  f := filebyname(filename);
  result:=copy(name(f),2,2);
  if SameText(result, 'FE') then
    result := result + copy(name(f),5,3);
end;

procedure handleMasters(e:IInterface);
var i: integer;
    mstrs:TStringList;
begin
  mstrs := TStringList.Create;
  mstrs.Duplicates := dupIgnore;
  mstrs.Sorted := True;
  AddMasterIfMissing(patchFile, getfilename(GetFile(MasterOrSelf(e))));
  ReportRequiredMasters(e, mstrs, true, true);
  for i:=0 to mstrs.Count-1 do begin
    AddMasterIfMissing(patchFile, mstrs[i]);
  end;
end;

/// copy winning parent and grandparent of r
procedure handleParents(r:IInterface);
var parent, grandParent: IInterface;
    contName:string;
begin
  parent := ChildrenOf(GetContainer(r));
  if assigned(parent) then begin
    contName := name(GetContainer(parent));
    if ContainsText(contName,'GRUP World Children of ') or 
       ContainsText(contName,'GRUP Exterior Cell Sub-Block ') then begin
      grandParent := ChildrenOf(GetContainer(parent));
      if assigned(grandParent) then copyWithMasters(WinningOverride(grandParent));
    end;
    copyWithMasters(WinningOverride(parent));
  end;
end;

function normCopy(r:IInterface): IInterface;  // (no)
begin
  handleParents(r);
  result := copyWithMasters(r);
end;

function normCopyWithPrefix(r:IInterface; aPrefixRemove, aPrefix, aSuffix: string): IInterface;  // (no)
var parent, grandParent: IInterface;
    contName:string;
begin
  handleParents(r);
  result := copyWithMastersWithPrefix(r, aPrefixRemove, aPrefix, aSuffix);
end;

/// copy e with its required masters
function copyWithMasters(e: IInterface): IInterface;
begin
  handleMasters(e);
  result := wbCopyElementToFile(e, patchFile, false, true);
end;

/// copy e as new (new id) with prefix with its required masters
function copyWithMastersWithPrefix(e: IInterface; aPrefixRemove, aPrefix, aSuffix: string): IInterface;
var i: integer;
    mstrs:TStringList;
begin
  handleMasters(e);
  result := wbCopyElementToFileWithPrefix(e, patchFile, true, true, aPrefixRemove, aPrefix, aSuffix);
end;

end.

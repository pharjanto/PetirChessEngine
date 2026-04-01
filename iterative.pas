unit uiterative;

interface
uses header;
function iterative(level,giliran,tipe:integer;data:tdata):integer;

implementation

function iterative(level,giliran,tipe:integer;data:tdata):integer;
var l,nilai,nilai2,nilai3:integer;
begin
  l:=4;
  if not use_mtdf then
  begin
    toplevel:=l-1;
    nilai2:=mainsearch(l-1,giliran,_NODEMAX,-_INFINITY-toplevel+1,_INFINITY+toplevel-1,data,false,0,0);
    toplevel:=l;
    nilai:=mainsearch(l,giliran,_NODEMAX,-_INFINITY-toplevel+1,_INFINITY+toplevel-1,data,false,0,0);
  end else
  begin
    toplevel:=l-1;
    nilai2:=mtdf(data,l-1,giliran,0);
    toplevel:=l;
    nilai:=mtdf(data,l,giliran,0);
  end;

  while l<level do
  begin
    clearkiller;
    inc(l);
    toplevel:=l;
    if not use_mtdf then
      nilai3:=aspiration(l,giliran,tipe,nilai2,data)
    else
      nilai3:=mtdf(data,l,giliran,nilai2);

    if (nilai3>_INFINITY) or (nilai3<-_INFINITY) then break;

    nilai2:=nilai;
    nilai:=nilai3;

  end;
  result:=nilai3;
end;


end.

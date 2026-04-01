unit test_suites;

interface
uses classes,header;
  type
  ttest=class(tthread)
      testfile:string;
      constructor create(testfile2:string);
      procedure execute;override;
      procedure terminated(sender:tobject);
  end;


procedure start_test(testfile:string);

implementation
uses customboard,unit1,windows,uiterative,hashing_header,sysutils,notation;

constructor ttest.create;
begin
  freeonterminate:=true;
  onterminate:=terminated;
  testfile:=testfile2;
  inherited create(false);
end;

procedure parse_epd(s:string;var data:tdata;var giliran,answer:integer);
var p:integer;
ns:string;  wtm:boolean;
begin
  p:=pos('bm',s);
  ns:=copy(s,1,p-1);
  readnotation(ns,data,wtm);
  if wtm then giliran:=_SISIPUTIH else giliran:=_SISIHITAM;
  fillbitboard(data);
  s:=copy(s,p+3,length(s)-(p+3));
  p:=pos(';',s);
  s:=copy(s,1,p-1);
  if s[length(s)]='+' then s:=copy(s,1,length(s)-1);
  ns:=shortnotationtolong(s,data,giliran);
  answer:=notationtomove(ns,data,giliran);

end;


procedure analyze(data:tdata;giliran:integer);
  procedure init;
  var a,b:integer;
  begin
      cetc:=0;
      total_node:=0;
      total_node2:=0;
      ai_side:=giliran;
      hash_hit:=0;
      timepassed:=0;
      testsolved:=false;
      clockwhite:=realclock;
      clockblack:=realclock;
      lazy_margin1a:=lazy_margin1;
      lazy_margin2a:=lazy_margin2;
      lazy_margin3a:=lazy_margin3;

      fillchar(killer0,sizeof(killer0),_NO_MOVE);
      fillchar(killer1,sizeof(killer1),_NO_MOVE);

      cleartable;
      co_hash:=0;totalco:=0; hashco:=0;
      lazyexit:=0;
      fpruning:=0;efpruning:=0;razor:=0;
      cofirst:=0;
      computer_thinking:=true;

      for b:=0 to HIST_SIZE do
      begin
        //historyb[b]:=0;historyw[b]:=0;
      end;
      startclock:=gettickcount;
      if usetimer then timelimit:=realclock;
  end;
var l:integer;
begin

  init;
  l:=toplevel;
  nilai:=iterative(toplevel,giliran,_NODEMAX,data);
  toplevel:=l;
end;

procedure ttest.execute;
var f:textfile;
s:string;
data:tdata;giliran,answer,no,totalsolved,ref:integer;
tnode:int64;
begin

  assignfile(f,testfile);
  reset(f);
  no:=0;totalsolved:=0;
  ref:=gettickcount;
  tnode:=0;
  timepassed:=0;timelimit:=999;
  while not eof(f) do
  begin
    readln(f,s);
    inc(no);
    parse_epd(s,data,giliran,answer);


    analyze(data,giliran);
    inc(tnode,total_node);
    if testsolved then inc(totalsolved);
//    if no=2 then exit;
  end;
  ref:=gettickcount-ref;
end;

procedure ttest.terminated;
begin
  runningtest:=false;

end;

procedure start_test(testfile:string);
var t:ttest;
begin

  t:=ttest.create(testfile);
end;

end.

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes,  Controls, Forms,
  Dialogs, udata,  ToolWin, ComCtrls, Menus,header, hashing, ExtCtrls  ;



type
  tsearch=class(tthread)
    constructor create;
    procedure execute;override;
    procedure terminated(sender:tobject);
  end;

  TForm1 = class(TForm)

    Imageself: TImage;

    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);

  private
    lastsavedfile:string;
    procedure make(moves:integer);
    { Private declarations }
  public
    defaultdir:string;
    chess_sets,giliran:byte;

    procedure init_var;
    procedure start_new_game;
    procedure init_search;




    { Public declarations }
  end;

  function fstring(s:string;w:byte):string;

var
  thr_search:tsearch;
  Form1: TForm1;

  level,nilai:integer;
  intvmsg:integer;
//  white_time,black_time:integer;


implementation
uses movgen, bitboard,makemove,perft_test,search,evalmask,tools,
ueval, valid, uiterative,
  hashing_header, notation,usee,repetition,opening_book,
  test_suites,winboard;


var
  moving:boolean;
  piece_moving:shortint;
  x_asal,y_asal:byte;
  piece_rect:trect;


{$R *.dfm}

procedure stop_thinking;
begin
    stop_process:=true;
    repeat
    until computer_thinking=false;
end;

function fstring(s:string;w:byte):string;
var a,n:integer;
t:string;
begin
  t:=s;
  n:=w-length(s);
  for a:=1 to n do
    t:=t+' ';
  fstring:=t;
end;

procedure updatetimer(giliran:byte);
begin
  if usetimer then
  begin
     if modetime=MINUTES_GAME_INCREMENT then
     begin
       if giliran=_SISIPUTIH then inc(clockwhite,rincrement)
       else inc(clockblack,rincrement);
     end;
     if (modetime=SECONDS_MOVE) then
     begin
        clockblack:=realclock;
        clockwhite:=realclock;
     end;
     if (modetime=MOVES_MINUTES) and (jumlahlangkah>=rmoves*2) then
     begin
       clockwhite:=realclock;
       clockblack:=realclock;
       jumlahlangkah:=0;
     end;
  end;

end;


procedure killallthread;
begin
end;

procedure tsearch.terminated;
begin
  if not stop_process then
  begin
    form1.giliran:=3-form1.giliran;


    computer_thinking:=false;
  end;
end;

function settimelimit(giliran:integer):integer;
begin
  if (modetime=MINUTES_GAME) or (modetime=MINUTES_GAME_INCREMENT) then
  begin
    if (giliran=_SISIHITAM) then
    begin
      if jumlahlangkah<=90 then
        result:=clockblack div (60-jumlahlangkah div 2)-2
      else
      begin
        result:=clockblack div 30;
      end;
    end else
    begin
      if jumlahlangkah<=90 then
        result:=clockwhite div (60-jumlahlangkah div 2)-2
      else
      begin
        result:=clockwhite div 30;
      end;
    end;
    if result=0 then result:=1;
  end else
  if (modetime=MOVES_MINUTES) then
  begin
    if giliran=_SISIHITAM then
      result:=clockblack div ((rmoves+1)-(jumlahlangkah div 2))
    else
      result:=clockwhite div ((rmoves+1)-(jumlahlangkah div 2));
  end else
  if modetime=SECONDS_MOVE then
    result:=realclock;
//  form1.caption:=inttostr(result div 4);
end;


procedure tform1.init_search;
var a,b:integer;
begin

  perft_result:=0;
  stalemate:=false;
  cetc:=0;
  total_node:=0;
  total_node2:=0;
  ai_side:=giliran;
  hash_hit:=0;
  timepassed:=0;
  lazy_margin1a:=lazy_margin1;
  lazy_margin2a:=lazy_margin2;
  lazy_margin3a:=lazy_margin3;
  testsolved:=false;
  cleartable2;
  co_hash:=0;totalco:=0; hashco:=0;
  lazyexit:=0;
  fpruning:=0;efpruning:=0;razor:=0;
  cofirst:=0;
  computer_thinking:=true;
  clearkiller;

  for a:=-6 to 6 do
  for b:=0 to 67 do
  begin
    historyb[a,b]:=historyb[a,b] div 128;
    historyw[a,b]:=historyw[a,b] div 128;
  end;
  startclock:=gettickcount;
  timelimit:=999999999;
  if usetimer then
  begin
    timelimit:=settimelimit(giliran);
    if outofbook=0 then timelimit:=round(timelimit*1.5);
  end;

end;


function checkresult(data:tdata):boolean;
var ml:tmovelist;jml,sc:integer;
b:boolean;
begin
  result:=false;
  if isdraw(data,b) then
  begin

    form1.giliran:=_GAMEOVER;
    if usewinboard then send_winboard('1/2-1/2 {draw by insufficient material');
    result:=true;
  end;
  if stalemate then
  begin

    form1.giliran:=_GAMEOVER;
    if usewinboard then send_winboard('1/2-1/2 {stalemate}');
    result:=true;
  end;

  if white_checked(data) then
  begin
    white_evasion(data,ml,jml,sc);
    if jml=0 then
    begin

      form1.giliran:=_GAMEOVER;
      if usewinboard then send_winboard('0-1 {white mated}');
      result:=true;
    end;
  end;
  if black_checked(data) then
  begin
    black_evasion(data,ml,jml,sc);
    if jml=0 then
    begin

      if usewinboard then send_winboard('1-0 {black mated}');
      form1.giliran:=_GAMEOVER;
      result:=true;
    end;
  end;
end;

Procedure tsearch.execute;
var pp,resign,tempb:boolean;
a,ep:byte;
s:string;
m:integer;
begin
  if form1.giliran=_GAMEOVER then exit;
  stop_process:=false;
//  toplevel:=6;
  level:=toplevel;
  setthreadpriority(thr_search.Handle,thread_priority);


  form1.init_search;
  ref2:=gettickcount;
  mmoves:=_NO_MOVE;

// nilai:=mainsearch(level*fractional_ply,form1.giliran,_NODEMAX,-_INFINITY-100,_INFINITY+100,data,false,0,a);
  if outofbook<=4 then
  begin
    mmoves:=searchbook(data,form1.giliran);
    if not isvalid(data,mmoves,form1.giliran) then mmoves:=_NO_MOVE else
//    send_winboard('tellall book moves');
  end;
  resign:=false;
  if mmoves=_NO_MOVE then
  begin
    inc(outofbook);

    if anotherdraw(data,form1.giliran)
    or anotherdraw2(data,form1.giliran)
    then
    begin
      send_winboard('offer draw');
    end;

    nilai:=iterative(level,form1.giliran,_NODEMAX,data);

{    if (nilai>=-12) and (nilai<=5) and (data.nilai_perwira_putih<=9) and (data.nilai_perwira_hitam<=9)
    then inc(draw_count);
    if (draw_count>=4) or anotherdraw(data) then
      send_winboard('offer draw');
}
    if nilai<=resign_value then inc(resign_count);
    if resign_count>=4 then
    begin
      resign:=true;
    end;
  end;

  if stalemate then
  begin

    form1.giliran:=_GAMEOVER;
    if usewinboard then send_winboard('1/2-1/2 {stalemate}');
    exit;
  end;



  if stop_process then
  begin
    computer_thinking:=false;
    exit;
  end;
  ref2:=gettickcount-ref2;
  ep:=data.ep;

  if form1.giliran=_SISIHITAM then
  begin
    makeblackmove(mmoves,data);
  end else
  begin
    makewhitemove(mmoves,data);
  end;

  if (data.nilai_perwira_putih=0) and (data.nilai_perwira_hitam=0) and
  (data.cp>=_KUDAPUTIH) and (data.cp<=_MENTRIPUTIH)
  then
  begin
    data.pawnending:=true;
  end;

  if usewinboard then
  begin
    s:=movetonotation(mmoves,ep,form1.giliran);
//    form1.Caption:=s;
    if not resign and (mmoves<>_NO_MOVE) then
      send_winboard('move '+s)
    else
    begin
      if ai_side=_SISIPUTIH then
       send_winboard('0-1 {white resigns}')
     else
       send_winboard('1-0 {black resigns}')
    end;
  end;
  if checkresult(data) then exit;
  if data.move50count>=101 then
  begin
    if usewinboard then
      send_winboard('1/2-1/2 {draw by 50 move rule}')
  end;


  if addrephash(data.hashkey,2-form1.giliran)=2 then
  begin
    if not usewinboard then
    begin

      form1.giliran:=_GAMEOVER;
    end else send_winboard('1/2-1/2 {draw by repetition}');
    exit;
  end;
  inc(jumlahlangkah);
  updatetimer(form1.giliran);


end;

procedure delete_data;
begin
 fillchar(historyb,sizeof(historyb),0);
 fillchar(historyw,sizeof(historyw),0);
 clearkiller;
 cleartable;

end;

procedure tform1.Start_New_Game;
begin
 initstate(data);
 outofbook:=0;
 resign_count:=0;
 giliran:=_SISIPUTIH;
 draw_count:=0;
 delete_data;
 jumlahlangkah:=0;
 initrepdata;

end;


procedure tform1.init_var;
begin
 timefactor:=4;
 runningtest:=false;
 form1.defaultdir:=getcurrentdir;
 chess_sets:=1;
 usetimer:=false;
 moving:=false;
 init_mask;
 killer0[-2]:=0;
 killer1[-2]:=0;
 killer0[-1]:=0;
 killer1[-1]:=0;
 inithashkey;
 inittable;
 initevalmask;
 players:=_PLAYERVSCOMP;
 toplevel:=8;

 form1.lastsavedfile:='';
 clockwhite:=0;clockblack:=0;
 thread_priority:=THREAD_PRIORITY_NORMAL;
 nullOK:=true;lazyOK:=true;futpruningOK:=true;qpruningOK:=true;

 if use_book then
 begin
 end;
 
end;

Procedure readini;
var f:text;
s:string;
begin
  assignfile(f,'petir.ini');
  reset(f);
  if ioresult=0 then
  begin
//    form1.Caption:='ada';
    while not eof(f) do
    begin
      readln(f,s);
      if (length(s)>=10) and (copy(s,1,8)='HASHSIZE') then
      begin

        s:=copy(s,10,length(s)-9);
        if s='1' then maxhash:=262144 div 8 else
        if s='2' then maxhash:=262144 div 4 else
        if s='4' then maxhash:=262144 div 2 else
        if s='8' then maxhash:=262144*1 else
        if s='16' then maxhash:=262144*2 else
        if s='32' then maxhash:=262144*4 else
        if s='64' then maxhash:=262144*8 else
        if s='128' then maxhash:=262144*16 else
        if s='256' then maxhash:=262144*32;
      end;
      maxhash:=maxhash*2;
    end;
  end;
  closefile(f);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  readini;
  init_var;
  start_new_game;

  fillchar(historyw,sizeof(historyw),0);
  fillchar(historyb,sizeof(historyb),0);

//  caption:=inttostr(sizeof(book));
        usewinboard:=true;
        start_winboard;

  if paramcount>0 then
  begin

    if (pos('xboard',paramstr(1))<>0) then
    begin
    end;
  end;

end;




procedure tform1.make(moves:integer);
var temp:tdata;
pp:boolean;
begin
     temp:=data;
     inc(jumlahlangkah);

     if giliran=_SISIPUTIH then
     begin
       makewhitemove(moves,data);
       if white_checked(data) then
       begin
         data:=temp;

         exit;
       end;
       if checkresult(data) then exit;
     end else
     begin
       makeblackmove(moves,data);
       if black_checked(data) then
       begin
         data:=temp;

         exit;
       end;
       if checkresult(data) then exit;
     end;
     if addrephash(data.hashkey,2-giliran)=2 then
     begin

        form1.giliran:=_GAMEOVER;

        exit;
     end;
     giliran:=3-giliran;

     updatetimer(3-giliran);
     if players<>_TWOPLAYERS then
       thr_search:=tsearch.create;

end;

constructor tsearch.create;
begin
  freeonterminate:=true;
  onterminate:=terminated;
  inherited create(false);
end;

procedure savesetting;
begin
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  savesetting;
end;

procedure savefile(filename:string);
begin
end;

procedure arrangelayout;
begin
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 if not usetimer then
 begin
   if giliran=_SISIPUTIH then inc(clockwhite)
   else inc(clockblack);

 end else
 begin
   if giliran=_SISIPUTIH then dec(clockwhite)
   else dec(clockblack);
   inc(timepassed);
 end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
 if usewinboard then form1.Hide
end;


procedure TForm1.Timer2Timer(Sender: TObject);
begin
  application.terminate;
end;

end.


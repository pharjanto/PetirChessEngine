unit header;

interface

const
  VERSION=1;

  a1=0;b1=1;c1=2;d1=3;e1=4;f1=5;g1=6;h1=7;
  a2=8;b2=9;c2=10;d2=11;e2=12;f2=13;g2=14;h2=15;
  a3=16;b3=17;c3=18;d3=19;e3=20;f3=21;g3=22;h3=23;
  a4=24;b4=25;c4=26;d4=27;e4=28;f4=29;g4=30;h4=31;
  a5=32;b5=33;c5=34;d5=35;e5=36;f5=37;g5=38;h5=39;
  a6=40;b6=41;c6=42;d6=43;e6=44;f6=45;g6=46;h6=47;
  a7=48;b7=49;c7=50;d7=51;e7=52;f7=53;g7=54;h7=55;
  a8=56;b8=57;c8=58;d8=59;e8=60;f8=61;g8=62;h8=63;

  RANK1=0;
  RANK2=1;
  RANK3=2;
  RANK4=3;
  RANK5=4;
  RANK6=5;
  RANK7=6;
  RANK8=7;

  _PIONPUTIH=1;
  _KUDAPUTIH=2;
  _GAJAHPUTIH=3;
  _BENTENGPUTIH=4;
  _MENTRIPUTIH=5;
  _RAJAPUTIH=6;
  _PIONHITAM=-1;
  _KUDAHITAM=-2;
  _GAJAHHITAM=-3;
  _BENTENGHITAM=-4;
  _MENTRIHITAM=-5;
  _RAJAHITAM=-6;

  PV_NODE=0;
  FAIL_LOW=1;
  FAIL_HIGH=2;

  _SISIPUTIH=1; //0 1
  _SISIHITAM=2;// 1 0
  _GAMEOVER=3;
  _NODEMAX=1;
  _NODEMIN=2;

  _NO_EP=10;
  _NOROKADE=64;
  _ROKADEPENDEK=65;
  _ROKADEPANJANG=66;
  _EN_PASSANT=67;
  _NO_MOVE=0;

  _TWOPLAYERS=0;
  _PLAYERVSCOMP=1;
  _COMPVSPLAYER=2;
  _COMPVSCOMP=3;

  NOROKADE=0;
  ROKADEPENDEK=1;
  ROKADEPANJANG=2;

  BITPUTIHSC=1;
  BITPUTIHLC=2;
  BITHITAMSC=4;
  BITHITAMLC=8;
  BITPUTIHNOC=3;
  BITHITAMNOC=12;

  RESULT_WHITE_WIN=0;
  RESULT_DRAW=1;
  RESULT_BLACK_WIN=2;

  PROMOSI_MENTRI=1;
  PROMOSI_KUDA=2;
  PROMOSI_GAJAH=3;
  PROMOSI_BENTENG=4;

  bit8mask:array [0..15] of word=(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,31678);

  LEVEL_NM=4;

  _HASHMOVE=0;
  _GOODCAPS=1;
  _KILLERMOVES1=2;
  _KILLERMOVES2=3;
  _KILLERMOVES3=4;
  _KILLERMOVES4=5;
  _OTHERMOVES=6;
  _BADCAPS=7;
  _FINISH=8;

  MINUTES_GAME=0;
  SECONDS_MOVE=1;
  MOVES_MINUTES=2;
  MINUTES_GAME_INCREMENT=3;
  FIXED_DEPTH=4;

  PONDER_OFF=0;
  PONDER_FILL_HASH=1;
  PONDER_GUESS=2;
  PONDER_COMBINE=3;


  _NILAI_PION=90;
  _NILAI_GAJAH=319;
  _NILAI_KUDA=312;
  _NILAI_BENTENG=500;
  _NILAI_MENTRI=975;
  _NILAI_RAJA=20000;
  nilai_piece:array[-6..6] of word=(_nilai_raja,_nilai_mentri,_nilai_benteng,_nilai_gajah,_nilai_kuda,_nilai_pion,0,_nilai_pion,_nilai_kuda,_nilai_gajah,_nilai_benteng,_nilai_mentri,_nilai_raja);

  _INFINITY=20000;

  HIST_SIZE=65536;

  posvertmask:array[0..63] of byte=
  (
    0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,
    3,3,3,3,3,3,3,3,
    4,4,4,4,4,4,4,4,
    5,5,5,5,5,5,5,5,
    6,6,6,6,6,6,6,6,
    7,7,7,7,7,7,7,7);

type
  tkillermove=integer;

  tmoverecord=record
    moves:Integer;
    score:integer;
  end;
  tmovelist=array[1..100] of tmoverecord;

  tarr=array[0..63] of shortint;

  tdata=record      
       	papan:tarr;
        ep:byte;
        flagrokade:byte;
        wc,bc:byte;
        move50count,cp:byte;
        nilai_perwira_putih,nilai_perwira_hitam:byte;
        ngajahhitam,ngajahputih:byte;
        pawnending,bishop_oppc:boolean;
        materialscore:integer;        
//        whitelc,blacklc,whitesc,blacksc:boolean;
        hashkey:int64;
        whitepieces,blackpieces,allpieces,allpiecesr90,allpiecesa8h1,allpiecesh8a1:int64;
        pawnblack,pawnwhite:int64;
        bishopblack,bishopwhite:int64;
        knightblack,knightwhite:int64;
        rookblack,rookwhite:int64;
        queenblack,queenwhite:int64;
        kingblack,kingwhite:int64;
        rookqueen,bishopqueen:int64;
  end;

var
        futpruningOK,lazyOK,qpruningOK,nullOK:boolean;
        etcOK:boolean=false;
        lazyts:integer;
        pawneval,knighteval,bishopeval,rookeval,queeneval,kseval,kpeval:integer;
        Q_MARGIN:integer=250;
        FUTIL_MARGIN:integer=200;
        thread_priority:integer=0;
        maxhash:integer=262144*4;
        RESIGN_VALUE:integer=-900;
        resign_count,draw_count:integer;
        total_node:int64;
        stalemate:boolean;
        total_node2:int64;
        players:integer;
        AI_side,toplevel:integer;
        use_mtdf:boolean=false;
        historyw,historyb:array[-6..6,0..67] of integer;
        killer0,killer1:array[-2..127] of tkillermove;
        co_hash,totalco,hashco,lazyexit,fpruning,efpruning,razor,cofirst:integer;
        LAZY_MARGIN1:integer=400;
        LAZY_MARGIN2:integer=230;
        LAZY_MARGIN3:integer=155;
        LAZY_MARGIN1a:integer;
        LAZY_MARGIN2a:integer;
        LAZY_MARGIN3a:integer;
        contemp_draw:integer=0;
        hash_hit,cetc:integer;
        inpondering:boolean;
        stop_process,thread_killed:boolean;
        maxdepth:integer;
        outofbook:integer;
        clockwhite,clockblack,realclock:integer;
        usetimer:boolean;
        timefactor,timepassed,timelimit:integer;
        side,mmoves:integer;
        hashkey:array[-6..6,0..63] of int64;
        rokadehashkey:array[0..255] of int64;
        enpassanthashkey:array[0.._NO_EP] of int64;
        startclock,barisitr:longint;
//        tu:integer=0;tu2:integer=0;
        maxext:real=0.5;
        jumlahlangkah:integer;
        computer_thinking:boolean=false;
        use_book:boolean=true;
        Ponder_type:byte=0;
        amoves:integer;

        FRACTIONAL_PLY:integer=8;
        SKAK_EXTENSION:integer=6;
        MATE_THREAT_EXTENSION:integer=4;

        RECAPTURE_PAWN_EXTENSION:integer=2;
        RECAPTURE_KNIGHT_EXTENSION:integer=4;
        RECAPTURE_ROOK_EXTENSION:integer=6;
        RECAPTURE_QUEEN_EXTENSION:integer=8;
        SINGLE_REPLY_EXTENSION:integer=6;
        TWO_REPLY_EXTENSION:integer=2;
        DOUBLE_SKAK_EXTENSION:integer=2;
        PUSHED_PAWN_EXTENSION_MIDGAME:integer=4;
        PUSHED_PAWN_EXTENSION_ENDGAME:integer=6;
        PUSHED_PAWN_EXTENSION_LATE_ENDGAME:integer=8;
        data:tdata;
        modetime,rmoves,rincrement:integer;
        runningtest,testsolved:boolean;
        testanswer:array[1..5] of integer;
        usewinboard:boolean=false;
        ref2:longint;
        ephashkey:int64;

implementation

end.

unit search;



interface
uses header;

var threat_move,curr_move:array[0..63] of integer;

function mainsearch(level,giliran,alpha,beta:integer;var data:tdata;nullmove:boolean;depth:integer;cext,lamoves:integer;nmtree:boolean;reduced:integer):integer;
function Q_search(giliran,alpha,beta:integer;var data:tdata;ply:integer;depth,cext,neval:integer;var nmmoves:integer):integer;
//function aspiration(level,giliran,tipe:integer;data:tdata):integer;
var rs:integer;
{$IFDEF stat}
var fl,fh,pvn:integer;
{$ENDIF}
implementation
uses ueval,makemove,tools,hashing,next,movgen,bitboard_mask,usee,repetition;
const margin:array[2..8] of integer=(18,24,32,40,60,100,150);
margingc:array[0..15] of integer=(5000,90,50,10,10,0,0,0,0,0,0,0,0,0,0,0);
var nmmoves:integer;
const noval=-200000;


procedure addhistory(rlevel,depth,moves,giliran:integer);
begin
  if giliran=_SISIPUTIH then
    inc(historyw[moves],(rlevel) * (rlevel) )
  else
    inc(historyb[moves],(rlevel) * (rlevel) );
  if (killer0[depth]<>moves) then
  begin
    killer1[depth]:=killer0[depth];
    killer0[depth]:=moves;
  end;

end;


function mainsearch;
var g,fase:integer;
temp:tdata;
ml,mlcap:tmovelist;
var curmovecap,curmovenoncap,jmlcap,jmlnoncap,newlevel,nlev,jml:integer;
tcext,t_alpha,t_beta,nilai,tempi,areduce:integer;
mbadcap,quiet:boolean;
sto:byte;
pp:boolean;
nullmoveok,incheck,mte,singular,isSingular:boolean;
h:int64;
goodcap,tempep:integer;
r,stat:byte;
tempnm,rlevel,legalmove,nl,moves,hmoves,tmoves:integer;
neval:integer;
//var tm:array[0..65535] of boolean;
label search1,search2,Nonullmove,search3;

begin
    if (timepassed>=timelimit) then exit;
    if stop_process then exit;


    if data.move50count>=101 then
    begin
      result:=CONTEMP_DRAW;exit;
    end;


    inc(total_node2);
    hmoves:=_NO_MOVE;
    isSingular:=false;
    if searchhash(data.hashkey,alpha,beta,level,giliran,nilai,hmoves,isSingular,data)
    and (alpha=beta-1)
    then
    begin
    {$IFDEF stat}
      inc(hashco);
    {$ENDIF}
      result:=nilai;exit;

    end;
//    fillchar(tm,sizeof(tm),false);
    h:=data.hashkey;
    rlevel:=level shr 3;

    mte:=false;
{    if depth>=maxdepth then
       ext:=false;
}
    if giliran=_SISIPUTIH then
    begin
      if white_checked(data) then
      begin
        incheck:=true;
        if cext>0 then
        begin
          if (data.nilai_perwira_putih+data.nilai_perwira_hitam>24) then
            inc(level,6)
          else
            inc(level,2);
        end;

        goto nonullmove;
      end
      else
        incheck:=false;
    end else
    begin
      if black_checked(data) then
      begin
        incheck:=true;
        if cext>0 then
        begin
          if (data.nilai_perwira_putih+data.nilai_perwira_hitam>24) then
            inc(level,6)
          else
            inc(level,2);
        end;

        goto nonullmove;
      end else
        incheck:=false;
    end;

    if (rlevel>=3) and (beta<_INFINITY-100) and (data.nilai_perwira_hitam>=3) and (data.nilai_perwira_putih>=3) and not nullmove
    and (materialvalue(giliran,data.materialscore)>=-500) and (alpha=beta-1)
    then
    begin
        tempep:=data.ep;
        case rlevel of
          9..64 : newlevel:=level-40;
          else newlevel:=level-32;
        end;
//        newlevel:=level-FRACTIONAL_PLY-r;
        nmmoves:=0;
        if data.ep<>_NO_EP then
        begin
          data.hashkey:=data.hashkey xor enpassanthashkey[data.ep];
          data.ep:=_NO_EP;
          data.hashkey:=data.hashkey xor ephashkey;
        end;
        areduce:=0;
        if newlevel<FRACTIONAL_PLY then
        begin
          if (data.nilai_perwira_putih<=9) and (data.nilai_perwira_hitam<=9) then
            nilai:=-q_search(3-giliran,-beta,-(beta-1),data,0,depth+1,cext,noval,tempnm)
          else
            nilai:=-q_search(3-giliran,-beta,-(beta-1),data,1,depth+1,cext,noval,tempnm);
          nmmoves:=tempnm;
        end
        else
          nilai:=-mainsearch(newlevel,3-giliran,-beta,-(beta-1),data,true,depth+1,cext,moves,true,0);
        if nilai>=beta then
        begin
          data.hashkey:=h;
          data.ep:=tempep;
          result:=nilai;exit;
        end else
        begin
          if (reduced>0)
          and ((nilai<=alpha-300) or
          (curr_move[depth-1] shr 7 and 127=nmmoves and 127))
          then
          begin
            level:=level+reduced;//areduce:=1;
          end;
        end;
        if (nilai=-_NILAI_RAJA+depth+2) then
        begin
{          if (reduced>0) and (areduce=0) then
            level:=level+reduced;}
          if rlevel<=4 then
          begin
            inc(level,8);
            dec(cext,8);
          end else
          begin
            inc(level,6);
            dec(cext,6);
          end;
          mte:=true;
          threat_move[depth]:=nmmoves;
        end else
        if ((nilai+80<alpha) ) and (cext>0) then
        begin
          threat_move[depth]:=nmmoves;
//          mte:=true;
          if (depth>=3) and (nmmoves<>0) then
          begin
            if (threat_move[depth-2] shr 7 and 127 =curr_move[depth-2] and 127)
            and (threat_move[depth-2]<>0)
             then
            begin
              if (threat_move[depth] shr 7 and 127=curr_move[depth-2] shr 7 and 127) and
              (threat_move[depth]<>0)
              then
              begin
                inc(level,6);dec(cext,6);mte:=true;
              end;
            end else
            begin
              if (threat_move[depth] shr 7 and 127=threat_move[depth-2] shr 7 and 127)
              and (threat_move[depth]<>0) and (threat_move[depth-2]<>0)
               then
              begin
                inc(level,6);dec(cext,6);mte:=true;
              end;
            end;
          end;
        end else
          threat_move[depth]:=0;
        data.hashkey:=h;
        data.ep:=tempep;
    end;
nonullmove:
    fase:=0;
    temp:=data;
    curmovecap:=0;
    tmoves:=_NO_MOVE;
    t_alpha:=alpha;t_beta:=beta;
    g:=-_INFINITY-100;
    legalmove:=0;
    nlev:=level-FRACTIONAL_PLY;
    tcext:=cext;
    goodcap:=0;
    singular:=false;
    rlevel:=level shr 3;

//    jml:=0;

    repeat
      neval:=noval;
      cext:=tcext;
      newlevel:=nlev;
      areduce:=0;
{      inc(anu7);
      if anu7=370 then
        inc(anu7);}
      if not incheck then
      begin
        {jika tidak diskak sebelum melangkah, maka panggil nextmove}
        nextmove(giliran,depth,data,moves,fase,hmoves,curmovecap,curmovenoncap,jmlcap,jmlnoncap,ml,mlcap,mbadcap,goodcap);
        if moves=_NO_MOVE then
           break;

        sto:=moves shr 7 and 127;
        if giliran=_SISIPUTIH then
        begin
          {karena tidak diskak sebelum melangkah, maka hanya dua kemungkinan pihak yang melangkah
          diskak setelah melangkah, yaitu jika melangkahkan raja ke petak yang diserang buah lawan
          atau karena open skak}
          if (data.papan[moves and 127]=_RAJAPUTIH) then
          begin
            {melangkahkan raja, maka cek apakah petak tujuan diserang oleh buah lawan}
            if white_attacked(data,sto) then
            begin
              continue;
            end;
          end else
          {jika bukan langkah raja, maka cek apakah langkah yang dilakukan menyebabkan open skak}
          if white_open_check(data,moves) then
          begin
            continue;
          end;
        end else
        begin
          if (data.papan[moves and 127]=_RAJAHITAM) then
          begin
            if black_attacked(data,sto) then
            begin
              continue
            end;
          end else
          if black_open_check(data,moves) then
          begin
            continue;
          end;
        end;
      end else
      begin
        {jika diskak sebelum melangkah, maka panggil nextevasion untuk meng-generate hanya langkah
         yang lolos dari skak}
        if nextevasion(giliran,data,moves,fase,hmoves,curmovecap,jml,jmlcap,ml)
        then begin
          result:=-_NILAI_RAJA+depth;
          exit;
        end;
        if moves=_NO_MOVE then
        begin
           break;
        end;
        sto:=moves shr 7 and 127;

        if (legalmove=0) and (cext>0) and not losingmaterial(data.materialscore,giliran) then
        begin
          {jumlah langkah yang bisa dilakukan hanya satu, maka extend}
          if jml = 1 then
            begin
              inc(newlevel,SINGLE_REPLY_EXTENSION);
              inc(nlev,SINGLE_REPLY_EXTENSION);
              inc(cext,8);inc(tcext,8);
              dec(newlevel,newlevel and 7);
            end;
          {double skak biasanya lebih berbahaya daripada skak tunggal,
          maka extensionnya ditambah sedikit}
          if jmlcap=2 then
          begin
            inc(newlevel,DOUBLE_SKAK_EXTENSION);
            inc(nlev,DOUBLE_SKAK_EXTENSION);
            dec(cext,DOUBLE_SKAK_EXTENSION);dec(tcext,DOUBLE_SKAK_EXTENSION);
          end;
          {Untuk peningkatakan kecepatan,
          Skak extension tidak dilakukan pada saat menskak lawan,
          tapi dlakukan pada saat akan menghindar dari skak}

          dec(cext,SKAK_EXTENSION);
          dec(tcext,SKAK_EXTENSION);

        end;
      end;


      if giliran=_SISIPUTIH then
        makewhitemove(moves,data)
      else
        makeblackmove(moves,data);

      curr_move[depth]:=moves;

      inc(legalmove);

      {masukkan posisi dalam sekunder hash key untuk pengecekan draw repetition}
      {tidak perlu menunggu sampai tiga kali, jika posisi yang sama telah terja dua kali
      dalam sebuah path, maka sudah dapat dianggap remis}
      if addrephash(data.hashkey,2-giliran)=1 then
      begin
        nilai:=contemp_draw;
        goto search3;
      end;



      if (data.nilai_perwira_putih=0) and (data.nilai_perwira_hitam=0)
      then
      begin
        if (data.cp=1) and (cext>0) then
        begin
          inc(newlevel,4);
          dec(cext,4);
        end;
        if (data.cp>=_KUDAPUTIH) and (data.cp<=_MENTRIPUTIH) { and (data.pawnending=false)}
        and (data.materialscore>=-385) and (data.materialscore<=385) and (cext>0)
        then
        begin
          if not incheck then
          begin
            dec(cext,24);
            inc(newlevel,24);
          end else
          begin
            dec(cext,18);
            inc(newlevel,18);
          end;
          goto search1;
        end;
      end;
      {cek apakah bisa melakukan pawn push extension}
      pp:=false;
      if (sto<=63) and (abs(data.papan[sto])=_PIONPUTIH)  and IsExtension(data,newlevel,giliran,moves,cext)
      and not incheck
      and not winningmaterial(data.materialscore,giliran) then
      begin
        pp:=true;
        goto search1;
      end;
      if (rlevel<=3) {and ((data.cp=0)) }and not incheck and not pp and (data.cp<10) and (beta-alpha=1)
      and (alpha>-700)
      then
      begin
        case rlevel of
        1:
          begin
              tempi:=materialvalue(giliran,data.materialscore)+captured_value(sto,temp);
              if (data.nilai_perwira_putih+data.nilai_perwira_hitam<=10) then
                inc(tempi,200);
              if ((tempi+210<t_alpha) )
              and not menskak2(temp,giliran,moves)
              and (data.nilai_perwira_putih>3) and (data.nilai_perwira_hitam>3)
              and not pawn_7_rank(giliran,data)
              then
              begin
                nilai:=tempi;
                goto search3;
              end;
          end;
          2:
          begin
              tempi:=materialvalue(giliran,data.materialscore)+captured_value(sto,temp);
              if (data.nilai_perwira_putih+data.nilai_perwira_hitam<=10) then
                inc(tempi,100);
              if ((tempi+250<t_alpha) )
              and not menskak2(temp,giliran,moves)
              and (data.nilai_perwira_putih>5) and (data.nilai_perwira_hitam>5)
              and not pawn_7_rank(giliran,data)
              then
              begin
                if (data.nilai_perwira_putih<=8) and (data.nilai_perwira_hitam<=8) then
                begin
                  dec(newlevel,8);
                  goto search1;
                end else
                begin
                  nilai:=tempi;
                  goto search3;
                end;
              end;
          end;
          3:
          begin
              tempi:=materialvalue(giliran,data.materialscore)+captured_value(sto,temp);
              if ((tempi+550<t_alpha) )
              and not menskak2(temp,giliran,moves)
              and (data.nilai_perwira_putih>8) and (data.nilai_perwira_hitam>8)
              and not pawn_7_rank(giliran,data)
              then
              begin
                nilai:=tempi;
                goto search3;
              end;
          end;
        end;
      end;

{
search reduction berdasarkan nilai evaluator
dasar logikanya : jika nilai sebelum lawan melangkah setelah ditambah margin
lebih kecil dari alpha, maka lawan melangkah akan memperburuk nilai itu sehingga
makin lebih kecil dari alpha
}

      if giliran=_SISIPUTIH then
      begin
        if not incheck and (rlevel<=8) and (rlevel>=2) and (depth>=2)
        and (beta-alpha=1)
        and not nmtree
        and ((data.cp=0))
        and not pawn_7_rank(_SISIPUTIH,data)
        and not mte
        and not good_move_white(data,sto)

        and (moves<>hmoves)
        and
        (
        ((data.nilai_perwira_putih>=9) and (data.nilai_perwira_hitam>=9))
        or
        ((data.nilai_perwira_putih>=5) and (data.nilai_perwira_hitam>=5) and (rlevel=2))
        )

//        and (data.materialscore-300<alpha)
        and not white_threat(data,moves,tempi)
        and not black_open_check(temp,moves)
        then
        begin
          nilai:=eval(data,giliran,-_INFINITY,_INFINITY,true);
          neval:=-nilai;
          if (nilai+tempi+margin[rlevel]+40<t_alpha)
          and not pawn_6_rank(giliran,data)
           then
          begin
            dec(newlevel,24);
            areduce:=24;
          end else
          if nilai+tempi+margin[rlevel]<t_alpha then
          begin
            dec(newlevel,16);areduce:=16;
          end else
          if nilai+tempi+margin[rlevel]-5<t_alpha then
          begin
            dec(newlevel,8);areduce:=8;
          end else
          if (goodcap>1) and (tempi=0) then
          begin
            if goodcap>=5 then
            begin
              dec(newlevel,16);areduce:=16;
            end else
            begin
              dec(newlevel,8);areduce:=8;
            end;
          end else
          if (tempi>0) and (nilai+margin[rlevel]+40+tempi shr 1 <t_alpha) then
          begin
            dec(newlevel,6);
            areduce:=6;
          end;
          //if (newlevel<Fractional_ply) then goto search2;
        end;
      end else
      begin
        if not incheck and (rlevel<=8) and (rlevel>=2) and (depth>=2)
        and (beta-alpha=1)
        and not nmtree
        and ((data.cp=0))
        and not pawn_7_rankb(data)
        and (moves<>hmoves)
        and not mte
        and not good_move_black(data,sto)


        and
        (
        ((data.nilai_perwira_putih>=9) and (data.nilai_perwira_hitam>=9))
        or
        ((data.nilai_perwira_putih>=5) and (data.nilai_perwira_hitam>=5) and (rlevel=2))
        )

//        and (data.materialscore-300<alpha)
        and not black_threat(data,moves,tempi)
        and not white_open_check(temp,moves)   then
        begin
          nilai:=eval(data,giliran,-_INFINITY,_INFINITY,true);
          neval:=-nilai;
          if (nilai+tempi+margin[rlevel]+40<t_alpha)
          and not pawn_6_rank(giliran,data)
           then
          begin
            dec(newlevel,24);
            areduce:=24;
          end else
          if nilai+tempi+margin[rlevel]<t_alpha then
          begin
            dec(newlevel,16);
            areduce:=16;
          end else
          if nilai+tempi+margin[rlevel]-5<t_alpha then
          begin
            dec(newlevel,8);
            areduce:=8;
          end else
          if (goodcap>1) and (tempi=0)  then
          begin
            if goodcap>=5 then
            begin
              dec(newlevel,16);areduce:=16;
            end else
            begin
              dec(newlevel,8);areduce:=8;
            end;
          end else
          if (tempi>0) and (nilai+margin[rlevel]+40+tempi shr 1 <t_alpha) then
          begin
            dec(newlevel,6);
            areduce:=6;
          end;

          //if (newlevel<Fractional_ply) then goto search2;
        end;
      end;

      if (newlevel<8){ and (data.cp=0) }then
      begin
        if (giliran=_SISIPUTIH) then
        begin
          if white_forkandpin(sto,data) and (cext>0) then
          begin
{            if (areduce<>0) then
              inc(newlevel,areduce)
            else}
            begin
              newlevel:=8;cext:=0;
            end;
            goto search1;
          end;
        end else
        begin
          if black_forkandpin(sto,data) and (cext>0) then
          begin
{            if (areduce<>0) then
              inc(newlevel,areduce)
            else}
            begin
              newlevel:=8;cext:=0;
            end;
            goto search1;
          end;
        end;
      end;

      if (moves=hmoves) and isSingular and (cext>0) then
      begin
        inc(newlevel,6);
        dec(cext,6);
        goto search1;
      end;

search1:
      if newlevel<FRACTIONAL_PLY then
      begin
          nilai:=-q_search(3-giliran,-t_beta,-t_alpha,data,1,depth+1,cext,neval,tempnm)
      end
      else
        nilai:=-mainsearch(newlevel,3-giliran,-t_beta,-t_alpha,data,false,depth+1,cext,moves,nmtree,areduce);
search2:
      begin

        if  (nilai>t_alpha) {and (level>1)} and (nilai<beta) and (legalmove>1) then
        begin
         {$IFDEF stat}
          inc(rs);
          {$ENDIF}
          if (goodcap>0) and ((data.cp=0) or mbadcap) and (newlevel>=8) and not issingular and (cext>0) then
          begin
            if rlevel<=4 then
            begin
              inc(newlevel,8);dec(cext,8);
            end else
            begin
              inc(newlevel,4);dec(cext,4);
            end;
            if goodcap=1 then
              dec(newlevel,4);
          end else
            inc(newlevel);

          if newlevel<FRACTIONAL_PLY then
          begin
            nilai:=-q_search(3-giliran,-beta,-alpha,data,1,depth+1,cext,noval,tempnm);
          end
          else
            nilai:=-mainsearch(newlevel,3-giliran,-beta,-alpha,data,false,depth+1,cext,moves,nmtree,areduce);
        end;

search3:
        if nilai>g then
        begin
          g:=nilai;
          if nilai>t_alpha then
          begin
            tmoves:=moves;

            if (alpha>-1000) and ((data.cp=0) or mbadcap) and (materialvalue(giliran,data.materialscore)<=5) and (nilai-t_alpha>200) and (nilai<10000) then
            begin
              singular:=true;
            end else
              singular:=false;
            t_alpha:=nilai;
            if g>=beta then
            begin
              if ((data.cp=0) or mbadcap) and not incheck then
                addhistory(rlevel,depth,moves,giliran);
              {$IFDEF stat}
             inc(totalco);
             if legalmove=1 then inc(cofirst);
             {$ENDIF}
             delrephash(data.hashkey,2-giliran);
             data:=temp;
             break;
           end;
          end;
        end;
        t_beta:=t_alpha+1;
      end; //tipe=_NODEMAX
      delrephash(data.hashkey,2-giliran);
      data:=temp;
    until 1=2;
    if (timepassed>=timelimit) or stop_process then
    begin
      exit;
    end;
    nmmoves:=0;
    if legalmove=0 then
    begin
      tmoves:=_NO_MOVE;
      result:=contemp_draw;
      g:=result;
    end else
    begin
      result:=g;
      nmmoves:=tmoves;
      if tmoves=_NO_MOVE then
        tmoves:=hmoves;
    end;
    IF g<=alpha THEN
    begin
       {$IFDEF stat}
       inc(fl);
       {$ENDIF}
       addtable(h,giliran,level,tmoves,g,FAIL_LOW,singular);

    end ELSE if g>=beta then
    begin
        addtable(h,giliran,level,tmoves,g,FAIL_HIGH,singular);
        {$IFDEF stat}
        inc(fh);
       {$ENDIF}
    end
    else
    begin
        addtable(h,giliran,level,tmoves,g,PV_NODE,singular);
        {$IFDEF stat}
        inc(pvn);
       {$ENDIF}
        if giliran=_SISIPUTIH then
          inc(historyw[tmoves],(rlevel) )
        else
          inc(historyb[tmoves],(rlevel) );

    end;
end;


function Q_search;
var
temp:tdata;
ml:tmovelist;
tstat:byte;
incheck:boolean;
tempnm,sc,t_alpha,t_beta,g,a,jml,nilai,e,sto,sfrom:integer;
begin
  nmmoves:=0;
  if giliran=_SISIPUTIH then
     incheck:=white_checked(data)
  else
     incheck:=black_checked(data);

  if not incheck then
  begin
    if neval=noval then
      e:=eval(data,giliran,alpha,beta)
    else
      e:=neval;
    if (ply>0) and (e>alpha)  and (cext>0) then
    begin
      nilai:=materialvalue(giliran,data.materialscore);
      if (nilai<0) and (nilai+80<alpha)
      then
      begin
        result:=mainsearch(8,giliran,alpha,beta,data,false,depth,0,0,false,0);
        exit;
      end;
    end;

    begin
      if e>=beta then
      begin
        result:=e;
        exit;
      end;

      if (e>alpha) then
        alpha:=e;
    end;
  end;

  if giliran=_SISIPUTIH then
  begin
      if incheck then
      begin
        white_evasion(data,ml,jml,sc);
        case jml of
         1: inc(ply);
         0: begin
              result:=-_NILAI_RAJA+depth;
              exit;
            end;
         end;
      end
      else
      begin
        if ply>0 then
          q_white_movgen(data,ml,jml)
        else
          white_movgen_caps2(data,ml,jml);
        if jml=0 then
        begin
          result:=e;exit;
        end;
      end;
  end else
  begin
      if incheck then
      begin
        black_evasion(data,ml,jml,sc);
        case jml of
         1: inc(ply);
         0: begin
              result:=-_NILAI_RAJA+depth;
              exit;
            end;
         end;
      end
      else
      begin
        if ply>0 then
          q_black_movgen(data,ml,jml)
        else
          black_movgen_caps2(data,ml,jml);
        if jml=0 then
        begin
          result:=e;exit;
        end;
      end;
  end;
  temp:=data;

//  if (ply=2) and not incheck then ply:=0;

  if not incheck then
    g:=e
  else
  begin
     g:=-_INFINITY-100;
  end;
  t_alpha:=alpha;
  t_beta:=beta;

  for a:=1 to jml do
  begin
    if a<>jml then
    nextbest_max(ml,a,jml);

    if not incheck then
    begin
      if ml[a].score<0 then
      begin
//        data:=temp;
        break;
      end;


      //jika hanya tersisa capture yang equal dan sudah mencari terlalu dalam
      //maka dihentikan saja

      if (ml[a].score=0) and ((ply<=-2)) and (alpha=beta-1)
//      and (e+nilai_piece[data.papan[sto]]<t_alpha)
      then
      begin
//        data:=temp;
        break;
      end;

      sto:=(ml[a].moves shr 7) and 127;
      if (alpha=beta-1) and (sto<=63) and (data.papan[sto]<>0) then
      begin
        if (e+nilai_piece[data.papan[sto]]+Q_MARGIN<t_alpha) and not menskak2(temp,giliran,ml[a].moves) and (((ml[a].moves shr 14) and 7)=0) then
          continue
      end;

      sfrom:=ml[a].moves and 127;

      if giliran=_SISIPUTIH then
      begin
          if (data.papan[sfrom]=_RAJAPUTIH) and white_attacked(data,sto) then
            continue else
          if white_open_check(data,ml[a].moves) then continue;
      end else
      begin
          if (data.papan[sfrom]=_RAJAHITAM) and black_attacked(data,sto) then
            continue
          else
          if black_open_check(data,ml[a].moves) then continue;
      end;
    end;  //if not incheck


    if giliran=_SISIPUTIH then
      makewhitemove(ml[a].moves,data)
    else
      makeblackmove(ml[a].moves,data);

    nilai:=-q_search(3-giliran,-t_beta,-t_alpha,data,ply-1,depth+1,cext,noval,tempnm);
    begin
      if nilai>=beta then
      begin
        data:=temp;
        nmmoves:=ml[a].moves;
        result:=nilai;exit;
      end;
      if nilai>g then
      begin
        g:=nilai;
        if nilai>t_alpha then
        begin
          t_alpha:=nilai;
        end;
      end;
    end;
    data:=temp;
  end;     //for a;
  result:=g

end;

end.

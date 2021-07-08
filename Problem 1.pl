

addChar([_|T],0,C,[C|T]):- !.

addChar([H|T],N,C,[H|K]):-
    N>0,
    NewN is N-1,
    addChar(T,NewN,C,K).

print([],_,_,_,_):- !.
print(_,_,_,S,S):- !.

print([H|T],Rows,Cols,Size,Count):-
    NewCount is Count+1,
    write('      '),
    ( 0 is mod(NewCount,Cols) -> write(H),nl ; write(H) ),
    print(T,Rows,Cols,Size,NewCount).



initialize(S,S,List,L):-
    addChar(List,S,'-',New_List),
    L = New_List, !.

initialize(Size,Count,List,L):-
    addChar(List,Count,'-',New_List),
    New_Count is Count+1,
    initialize(Size,New_Count,New_List,L).

init(R,C,List,L):-
    Size is (R*C)-1,
    numlist(0,Size,List),
    Count is 0,
    initialize(Size,Count,List,L).

% ************************************************************************
% ***********************************************************************

move(S,X,Y,Color,L,Snew):-
	top(S,X,Y,Color,L,Snew).

top([R,C],X,Y,Color,L,Snew):-
	R>0,
        New_R is R-1,
        N is (New_R*Y)+C,
        Snew = [New_R,C],
        addChar(L,N,Color,List).


move(S,X,Y,Color,L,Snew):-
	right(S,X,Y,Color,L,Snew).

right([R,C],X,Y,Color,L,Snew):-
	C< (Y-1),
        New_C is C+1,
        N is (R*Y)+New_C,
        Snew = [R,New_C],
        addChar(L,N,Color,List).


move(S,X,Y,Color,L,Snew):-
	left(S,X,Y,Color,L,Snew).

left([R,C],X,Y,Color,L,Snew):-
	C>0,
        New_C is C-1,
        N is (R*Y)+New_C,
        Snew = [R,New_C],
        addChar(L,N,Color,List).


move(S,X,Y,Color,L,Snew):-
	bottom(S,X,Y,Color,L,Snew).

bottom([R,C],X,Y,Color,L,Snew):-
	R<(X-1),
        New_R is R+1,
        N is (New_R*Y)+C,
        Snew = [New_R,C],
        addChar(L,N,Color,List).


% ************************************************************************
% ************************************************************************

swap(List,C,Element1,Element2,Final_List):-
    [_,E1] = Element1,
    [_,E2] = Element2,
    El1 = [C,E1],
    El2 = [C,E2],
    delete(List,El1 , New_List),
    delete(New_List, El2, New_List2),
    append([El2],New_List2,New_List3),
    append([El1],New_List3,New_List4),
    Final_List = New_List4.

getList(_,_,0,_,_,_,[],_,_,_,L,L,I,I):- !.
getList(List,Childs,N,Final_N,L1,L2,Tail,Rows,Cols,Fixed_Closed,Closed,L,I,NewI):-
    [L1,L2|Tail2] = List,
    [C,Start] = L1,
    [C,Goal] = L2,
    go(Start,Goal,Rows,Cols,C,Closed,FinalC,I,FinalI),
    (
         (FinalI==0) ->
          (   swap(Childs,C,L1,L2,Final_Childs),
              New_N is N-1,
              getList(Final_Childs,Childs,Final_N,Final_N,L3,L4,Final_Childs,Rows,Cols,Fixed_Closed,Fixed_Closed,L,FinalI,NewI) )

         ;

             Size is Rows*Cols,
             Count is 0,
             %print(FinalC,Rows,Cols,Size,Count),
             New_N is N-1,
             getList(Tail2,Childs,New_N,Final_N,L3,L4,New_Tail,Rows,Cols,Fixed_Closed,FinalC,L,FinalI,NewI)

    ).


setpoints(0,_,L,_,_,L):- !.
setpoints(N,[H|T],Closed,Rows,Cols,L):-
    [Color,[R,C]] = H,
    Index is (R*Cols)+C,
    addChar(Closed,Index,Color,New_List),
    New_N is N-1,
    Size is Rows*Cols,
    Count is 0,
    setpoints(New_N,T,New_List,Rows,Cols,L).


solve():-
    grid(X,Y),
    findall([Char,L], dot(Char,L),Childs),
    length(Childs,Len),
    init(X,Y,List,Closed),
    setpoints(Len,Childs,Closed,X,Y,List1),
    NO_Color is Len/2,
    getList(Childs,Childs,NO_Color,NO_Color,L1,L2,Tail,X,Y,List1,List1,FinalC,I,FinalI).


% ************************************************************************
% **********************************************************************


go(Start,Goal,Rows,Cols,Color,Closed,FinalC,I,FinalI):-
    write('start = '),write(Start),nl,
    write('goal = '),write(Goal),nl,
    write('Color = '),write(Color),nl,nl,
    path([Start],Closed,Goal,Rows,Cols,Color,I,FinalC,FinalI).

path([],Closed,_,_,_,_,I,Closed,I):-
	(   (I==0) -> write('No solution'), nl,nl, ! )
        ;
        (   (I==1) -> nl, !   ).

path([Goal|_],Closed,Goal,Rows,Cols,_,NewI,Closed,NewI):-
	write('A solution is found'), nl ,
	Size is Rows*Cols,
        Count is 0,
        print(Closed,Rows,Cols,Size,Count).

path(Open,Closed,Goal,Rows,Cols,Color,I,FinalC,FinalI):-
        [State|_] = Open,
        delete(Open, State, RestOfOpen),
        getchildren(State, Open, Closed, Rows, Cols, Color, Goal, Children),
	append(Children, RestOfOpen, NewOpen),
        [R,C] = State,
        N is (R*Cols)+C,
        addChar(Closed,N,Color,New_Closed),
        Size is Rows*Cols, Count is 0,
        write('Step : '),nl,
        print(New_Closed,Rows,Cols,Size,Count),

        (
         (
            ( member(Goal, Children) ) ->

            ( write('A solution is found'), nl ,
              New_I is 1,
              Size1 is Rows*Cols,
              Count1 is 0,
              print(New_Closed,Rows,Cols,Size1,Count1),
              path([], New_Closed, Goal, Rows, Cols, Color, New_I,FinalC,FinalI)  )

         )

         ;

         (   New_I is 0,
             path(NewOpen, New_Closed, Goal, Rows, Cols, Color, New_I,FinalC,FinalI)
            )
       ).



getchildren(State,Open,Closed,X,Y,Color,Goal,Children):-
    findall(Snew, can_move(State,Open,Closed,X,Y,Color,Goal,Snew),Children).


can_move(State, Open, Closed,Rows,Cols,Color,Goal,Next_State):-
	move(State,Rows,Cols,Color,Closed,Next_State),
        \+ member(Next_State, Open),
        [R,C] = Next_State,
        N is (R*Cols)+C,
        nth0(N,Closed,Element),
        (
            ( Element == '-' )

            ;

            (   Next_State == Goal )

        ).







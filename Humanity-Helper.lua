-- title:  Humanity's Helper: Global Mission Begins At Home.
-- author: ronynn
-- desc:   Explore your neighbourhood helping others.
-- script: lua

--game states
GINIT=0
GINTRO=1
GFADEOUT=2
GFADEIN=3
GPLAY=4
GOBJECT=5
GRESTART=6
GRESET=7

--constants of commands
CMD={
 N=1,S=2,W=3,E=4,UP=5,DOWN=6,IN=7,OUT=8,
	TAKE=9,DROP=10,USE=11,OPEN=12,EXAM=13,INV=14,
	WAIT=15,TALK=16,DESC=17,PUSH=18
}

--commands defined in gui
GUI={
 [1]={n="north",x1=9,y1=121,x2=15,y2=127},
	[2]={n="south",x1=9,y1=129,x2=15,y2=135},
	[3]={n="west",x1=1,y1=129,x2=7,y2=135},
	[4]={n="east",x1=17,y1=129,x2=23,y2=135},
	[5]={n="up",x1=1,y1=121,x2=7,y2=127},
	[6]={n="down",x1=17,y1=121,x2=23,y2=127},
	[7]={n="inside",x1=25,y1=121,x2=38,y2=127},
	[8]={n="outside",x1=25,y1=129,x2=38,y2=135},
	[9]={n="take object",x1=40,y1=121,x2=56,y2=127},
	[10]={n="drop object",x1=40,y1=129,x2=56,y2=135},
	[11]={n="use object",x1=58,y1=121,x2=74,y2=127},
	[12]={n="open object",x1=58,y1=129,x2=74,y2=135},
	[13]={n="examine object",x1=76,y1=121,x2=111,y2=127},
	[14]={n="show inventory",x1=76,y1=129,x2=111,y2=135},
	[15]={n="wait a turn",x1=113,y1=121,x2=129,y2=127},
	[16]={n="talk to object",x1=113,y1=129,x2=129,y2=135},
	[17]={n="describe room",x1=131,y1=121,x2=157,y2=127},
	[18]={n="push object",x1=131,y1=129,x2=157,y2=135},
}

--item room start with 1..X
INV=0   --item in players inventory
HIDE=-1 --item not yet discovered
VOID=-2 --item destroyed

--game variables
rold=1 --previous visited room
room=1 --current room of player
points=0 --score for the ending
turns=1 --how many turns the player played

--engine variables
ver="Humanity's Helper: GLobal Mission Begins At Home."
t=0 --frame counter for each frame
t0=0 --frame counter for animation
eff=0 --start sprite of fade effect
mx,my,mb=0,0,0 --mouse state
pressed=false --mouse pressing simulation
game=GINIT --game state
LINES={} --drawn lines on screen
SELECTED={} --drawn objects on screen that can be selected
callback=nil --calback function for selected gui action
screen={} --stored cover screen
lastcmd=0 --last clicked command in gui

--here you can set various test to override starting point
function tests()
--room=2
--sobjr(1,INV)
end

--game loop
function TIC()
	t=t+1
 mx,my,mb=mouse()
 --draw
	if game==GINIT then 
	 --first initialize
		tests()
		txt(ver,8)
		eventIntro()
		txt()
	 look() 
		game=GINTRO
	elseif game==GINTRO then
	 --draw intro
		if game==GINTRO then
			rect(0,129,240,7,1)
	 	print("[press z or x to start the game]",20,130,15,true,1,false)
		 if anykey() then game=GFADEOUT end
		end
	elseif game==GFADEOUT then
 	if t%5==1 then
		 eff=eff+1
 	end
		if fadeout()==1 then game=GFADEIN end
	elseif game==GFADEIN then
	 map(60,0,30,17,0,0,-1)
	 drawText()
	 if t%5==1 then
		 eff=eff+1 
 	end
		if fadein()==1 then game=GPLAY end
	elseif game==GPLAY then
	 --draw screen with scrolling text
	 map(60,0,30,17,0,0)
	 drawText()
	 findGui()
	elseif game==GOBJECT then
	 --draw object selection screen
	 map(60,0,30,17,0,0)
	 drawSelection()
		findGui()
	elseif game==GRESTART then
	 --dead/win screen
		map(60,0,30,17,0,0)
	 drawText()
		if anykey() then game=GRESET end
	elseif game==GRESET then
	 --reset game
 	if t%5==1 then
		 eff=eff+1
 	end
		if fadeout()==1 then reset() end
	end
end

--return true when any key is pressed
function anykey()
 for i=0,7 do
	 if btnp(i) then return true end
	end
	return false
end



--fadeout effect
function fadeout()
 for j=0,17 do
  for i=0,29 do
		 spr(264-eff,i*8,j*8,15)
		end
	end
	if eff==8 then
	 eff=0
		return 1
	else
	 return 0
	end
end

--fadein effect
function fadein()
 for j=0,17 do
  for i=0,29 do
		 spr(256+eff,i*8,j*8,15)
		end
	end
	if eff==8 then
	 eff=0
		return 1
	else
	 return 0
	end
end

--find selected gui element
function findGui()
 --quick move with arrows
	if btnp(0) then north() end
	if btnp(1) then south() end
	if btnp(2) then west() end
	if btnp(3) then east() end
	--mouse gui interaction
 for i=1,#GUI do
	 g=GUI[i]
	 if mx>=g.x1 and mx<=g.x2 and my>=g.y1 and my<=g.y2 then
		 print(g.n,163,125,14,true,1,true)
			c=pix(g.x1,g.y1)
			for i=g.x1,g.x2 do
			 for j=g.y1,g.y2 do
				 if pix(i,j)==c then pix(i,j,14) else pix(i,j,6) end
				end
			end
			if mb==true then
			 if pressed==false then
			  pressed=true
					game=GPLAY
				 command(i)
				end
			end
			if mb==false then
			 pressed=false
			end
			return
		end
	end
	pressed=false
end

--set state
function sstate(i,v)
 STATES[i]=v
end

--get state
function gstate(i)
 return STATES[i]
end

--set object room
function sobjr(i,r)
 OBJECTS[i].r=r
end

--get object room
function gobjr(i)
 return OBJECTS[i].r
end

--set new room direction (ri=room index,dir=CMD.,rto=room to index)
function sroomd(ri,dir,rto)
 r=ROOMS[ri]
 if dir==CMD.N then
	 r.n=rto
	elseif dir==CMD.S then
	 r.s=rto
	elseif dir==CMD.W then
	 r.w=rto
	elseif dir==CMD.E then
	 r.e=rto
	elseif dir==CMD.UP then
	 r.u=rto
	elseif dir==CMD.DOWN then
	 r.d=rto
	elseif dir==CMD.IN then
	 r.i=rto
	elseif dir==CMD.OUT then
	 r.o=rto
	else
	 err("Trying to set unknown direction "..dir.." for room "..ri)
	end
end

--get direction set in room (ri=room index,dir=CMD.)
function groomd(ri,dir)
 r=ROOMS[ri]
	d=0
 if dir==CMD.N then
	 d=r.n
	elseif dir==CMD.S then
	 d=r.s
	elseif dir==CMD.W then
	 d=r.w
	elseif dir==CMD.E then
	 d=r.e
	elseif dir==CMD.UP then
	 d=r.u
	elseif dir==CMD.DOWN then
	 d=r.d
	elseif dir==CMD.IN then
	 d=r.i
	elseif dir==CMD.OUT then
	 d=r.o
	else
	 err("Trying to get unknown direction "..dir.." from room "..ri)
	end
	if d==nil then d=0 end
	return d
end

--get count of carried items
function ginvc()
 c=0
	for i=1,#OBJECTS do
	 if OBJECTS[i].r==INV then c=c+1 end
	end
	return c
end

--show dead message
function die(s)
 txt ""
	txd("And you are dead. GAME OVER. Your helped "..points.." people. And you played for "..turns.." turns. Press z or x to restart.")
	game=GRESTART
end

--show win message
function win(s)
 txt ""
	txi("Congratulations, you finished this game after helping "..points.." people! And you played for "..turns.." turns. Press z or x to restart.")
	game=GRESTART
end

--movoment functions
function north() move(ROOMS[room].n,CMD.N) end
function south() move(ROOMS[room].s,CMD.S) end
function west() move(ROOMS[room].w,CMD.W) end
function east() move(ROOMS[room].e,CMD.E) end
function up() move(ROOMS[room].u,CMD.UP) end
function down() move(ROOMS[room].d,CMD.DOWN) end
function inside() move(ROOMS[room].i,CMD.IN) end
function outside() move(ROOMS[room].o,CMD.OUT) end

--execute commands from gui
function command(c)
 lastcmd=c
 if c==CMD.N then
	 north()
	elseif c==CMD.S then
	 south()
	elseif c==CMD.W then
  west()
	elseif c==CMD.E then
	 east()
	elseif c==CMD.UP then
	 up()
	elseif c==CMD.DOWN then
	 down()
	elseif c==CMD.IN then
	 inside()
	elseif c==CMD.OUT then
	 outside()
	elseif c==CMD.TAKE then
	 getSelection(room,room,take,"There is nothing here that can be taken.")
	elseif c==CMD.DROP then
	 getSelection(INV,INV,drop,"You aren't carrying anything.")
	elseif c==CMD.USE then
	 getSelection(room,INV,use,"You don't carry or see anything useable.")
	elseif c==CMD.OPEN then
	 getSelection(room,INV,open,"You don't carry or see anything openable.")
	elseif c==CMD.PUSH then
	 getSelection(room,INV,push,"You don't see anything that can be pushed here.")
	elseif c==CMD.TALK then
	 getSelection(room,room,talk,"You don't see anything to talk to here.")
	elseif c==CMD.EXAM then
	 getSelection(room,INV,examine,"You don't carry or see anything here for examination.")
	elseif c==CMD.WAIT then
	 wait()
	elseif c==CMD.DESC then
	 clearText()
	 look()
	elseif c==CMD.INV then
	 inventory()
	else
	 txi("Unknown command #"..c)
	end
end

--wordwrap
function splittokens(s)
 local res = {}
 for w in s:gmatch("%S+") do
  res[#res+1] = w
 end
 return res
end

--clears text on screen
function clearText()
 LINES={}
end

--draw text on screen
function drawText()
 for i=1,#LINES do
	 s=LINES[i]
		print(s.t,6,i*7-2,s.c,true,1,true)
	end
end

--write text to screen,max 16 lines and 56chars per line
function txt(str,col)
 col=col or 15
	str=str or ""
	if str=="" then
  table.insert(LINES,{t=" ",c=col})
		if #LINES>16 then table.remove(LINES,1) end
		return
	end
	li=splittokens(str)
	size=0
	s=""
	for i=1,#li do
		word=li[i]
		wsiz=#word
		if size+wsiz+1<=56 then
		 s=s..word.." "
			size=size+wsiz+1
		else
		 table.insert(LINES,{t=s,c=col})
			if #LINES>16 then table.remove(LINES,1) end
			s=word.." "
			size=wsiz+1
		end
	end
	if s~="" then
	 table.insert(LINES,{t=s,c=col})
		if #LINES>16 then table.remove(LINES,1) end
	end
end

--information text
function txi(s) txt(s,9) end
--death text
function txd(s) txt(s,6) end

--searchs what can be selected
function getSelection(r1,r2,cb,msg)
 SELECTED={}
	for i=1,#OBJECTS do
	 if OBJECTS[i].r==r1 or OBJECTS[i].r==r2 then
		 table.insert(SELECTED,i)
		end
	end
	cnt=#SELECTED
	if cnt>0 then
	 if cnt==1 then
		 cb(SELECTED[1])
		else
	  game=GOBJECT
		 callback=cb
		end
	else
	 txi(msg)
	end
end

--show items for selection
function drawSelection()
 for i=1,#SELECTED do
	 o=OBJECTS[SELECTED[i]]
		w1=#o.n*4
		h1=6
		x1=6
		y1=i*7-2
		x2=x1+w1
		y2=y1+h1
		if mx>=x1 and mx<=x2 and my>=y1 and my<=y2 then
 		rect(x1,y1,w1,h1,11)
			if mb==true then
			 game=GPLAY
			 callback(SELECTED[i])
			end
		end
		print(o.n,x1,y1,14,true,1,true)
	end
	print(GUI[lastcmd].n,163,125,14,true,1,true)
end

--describe room,items,exits
function look()
 --room description
 describe()
	if game==GRESTART then return end
	--what player sees
	s=""
	for i=1,#OBJECTS do
	 o=OBJECTS[i]
	 if o.r==room then
			s=separate(s,o.n)
		end
	end
	if s~="" then
	 txt("You see "..s..".",11)
	else
	 txt("There is nothing here.",11)
	end
	--where can player go
	s=""
	r=ROOMS[room]
 s=lookExit(s,r.n,CMD.N)
	s=lookExit(s,r.s,CMD.S)
	s=lookExit(s,r.w,CMD.W)
	s=lookExit(s,r.e,CMD.E)
	s=lookExit(s,r.u,CMD.UP)
	s=lookExit(s,r.d,CMD.DOWN)
	s=lookExit(s,r.i,CMD.IN)
	s=lookExit(s,r.o,CMD.OUT)
	if s~="" then
	 txt("You can go "..s..".",13)
	else
	 txt("There is no exit here.",13)
	end
	turn()
end

--get exit description
function lookExit(s,r,cmd)
 if r~=nil and r>0 then
	 s=separate(s,GUI[cmd].n) 
	end
	return s
end

--add separator when concaceating strings
function separate(s,s1)
 if s~="" then
	 s=s..", "
	end
	s=s..s1
	return s
end

--show inventory
function inventory()
 s=""
 for i=1,#OBJECTS do
	 o=OBJECTS[i]
		if o.r==INV then
		 s=separate(s,o.n)
		end
	end
	if s~="" then
	 txt("You are carrying "..s..".",14)
	else
	 txt("You are carrying nothing.",14)
	end
end

--move player to new room
function move(r,cmd)
 d=GUI[cmd].n
 if r~=nil and r>0 then
	 if eventBeforeMove(room,r)==1 then
 	 clearText()
	  txt("You are going "..d..".",13)
		 rold=room
		 room=r
		 look()
		 eventAfterMove(rold,room)
		end
	else
	 txd("You can't go "..d.."!")
	end
end

--room description
function describe()
 eventDescribe(room)
end

--each turn this command happens
function turn()
 turns=turns+1
	eventTurn()
end

--waiting a turn
function wait()
 txt("Waiting...",8)
	eventWait()
	turn()
end

--object description
function examine(i)
 txi("You are examining "..OBJECTS[i].n..".")
 eventExamine(i)
	turn()
end

--take object
function take(i)
 if eventBeforeTake(i)==1 then
	 o=OBJECTS[i]
	 o.r=INV
		txi("You take the "..o.n..".")
		eventAfterTake(i)
	end
	turn()
end

--drop object
function drop(i)
 if eventBeforeDrop(i)==1 then
  o=OBJECTS[i]
	 o.r=room
	 txi("You drop the "..o.n..".")
		eventAfterDrop(i)
	end
	turn()
end

--use object
function use(i)
 if eventUse(i)==1 then
  o=OBJECTS[i]
	 txi("You don't know how to use the "..o.n.." here.")
	end
	turn()
end

--talk to object
function talk(i)
 if eventTalk(i)==1 then
  o=OBJECTS[i]
	 txi("You can't talk to the "..o.n..".")
	end
	turn()
end

--push object
function push(i)
 if eventPush(i) then
  o=OBJECTS[i]
	 txi("You can't push the "..o.n..".")
	end
	turn()
end

--open object
function open(i)
 if eventOpen(i)==1 then
  o=OBJECTS[i]
	 txi("You can't open the "..o.n..".")
	end
	turn()
end































--------==YOUR GAME CODE GOES HERE==------------

--room exit directions,just use s,n,w,e,u,d,i,o for directions
ROOMS={
 [1]={s=2,n=3},
	[2]={n=1},
	[3]={s=1,n=4},
	[4]={s=3,n=5,e=9,w=6},
	[5]={s=4},
	[6]={w=8,s=7,e=4},
	[7]={n=6},
	[8]={e=6},
	[9]={w=4,d=10},
	[10]={s=11,w=14,e=12,u=9},
	[11]={n=10},
	[12]={e=13,w=10},
	[13]={w=12},
	[14]={e=10,s=15},
	[15]={n=14},
}

--list of objects, define name and room 1..X or INV,HIDE
OBJECTS={
 [1]={n="atlas",r=1},
	[2]={n="fish",r=3},
	[3]={n="soap",r=5},
	[4]={n="ball",r=HIDE},
	[5]={n="love letter",r=7},
	[6]={n="cash",r=HIDE},
	[7]={n="ticket",r=HIDE},
	[8]={n="the train",r=HIDE},
	[9]={n="the table",r=1},
	[10]={n="Lory",r=7},
	[11]={n="Bathing Man",r=10},
	[12]={n="Woman on a bench",r=12},
	[13]={n="My Friends",r=13},
	[14]={n="An Old Woman",r=15},
	[15]={n="A Frog Screaming at People",r=11},
}

--game states as simple number of your choice
STATES={
 [1]=0, --
	[2]=0, --
}

--intro of game, some story...
function eventIntro()
 txt("You have always wanted to help the world, change it for the better. But before making changes at such a huge scale, you need to scale up from the bottom, as they say, charity begins at home. You have decided to start by helping the people around you, then someday the world.",14)
end

--code for drawing something special on intro screen
function eventLogo()
 print("By R",20,10,2,true,2,false)
end

--describe rooms here, r=current room
function eventDescribe(r)
 if r==1 then
	 txt "This is your room, dimly lit in the evening with christmas lights. You like the lights. There is some 90's music playing on a stereo, you like the music. There is an atlas on a table, you were reading it."
	elseif r==2 then
	 txt "This is your balcony. You will probably miss the balcony when you leave the place. There is a tree surrounded by an apartment complex. You stand there for a second, with the evening wind rushing into your face"
	elseif r==3 then
	 txt "This is the kitchen. It's functional. You can't film it for a TV show though. But there's fish in the fridge."
	elseif r==4 then
	 txt "This is a corridor. Your bathroom is ahead."
	elseif r==5 then
	 txt "This is your bathroom. There is no water running right now. But there's a soap you can use for a shower when water shows up."
	elseif r==6 then
	 txt "This is another corridor."
	elseif r==7 then
	 txt "Lory is a friend of yours. He is sitting in his dimly lit room. Guess he likes it that way too. He is trying to write a love letter for his girlfriend, but seems to have discarded the idea since he can't decide what to call her in the letter. The letter is lying on a table."
	elseif r==8 then
	 txt "The corridor ends here to another of your neighbours door. There is a dog playing with his ball here. You forgot the dog's name. He was very sociable as a puppy but now barks at everyone, until someone points a camera at him. Drama Queen. Perhaps scared."
	elseif r==9 then
	 txt "This is another corridor that end with at the stairs. You can see the train tracks from here."
	elseif r==10 then
	 txt "You are on the street. There is a person taking a shower on a public tap. I guess it's for watering plants, but there are no plants here, only one tree, needs no watering. He looks upset for some reason."
	elseif r==11 then
	 txt "You are at the school grounds."
	elseif r==12 then
	 txt "There is a woman sitting on a bench. She looks curious yet upset. Perhaps she's thinking about something."
	elseif r==13 then
	 txt "This is a park. Your friends are hanging out here. You ask them to call you when they go to the park to play, but they never do. They look upset for some reason."
	elseif r==14 then
	 txt "You are at the train station. You see a board with the train timings. You can take one right now. Ofcourse you will need a ticket."
	elseif r==15 then
	 txt "This is the ticket counter. An old lady is sitting here knitting a sweater. You have to talk to her if you want to get the ticket."
	end
end

--describe objects here, i=object index
function eventExamine(i)
 if i==1 then
	 txt "This is a book that features maps from different countries and of the whole world. It also features the history of the formation of earth and about the formation of the continents."
	elseif i==2 then
	 txt "Fish is the primary diet in most parts of the world, not in your home though, some friend is using your refrigerator."
	elseif i==3 then
	 txt "It feels much better to soap up during a shower, it feels cleaner. Even ancient societies used some form of soap. But some soaps have harmful chemicals."
	elseif i==4 then
	 txt "Who could've invented it? From humans to animals, even birds play with balls. It's a naturally occuring shape, perhaps nature was coded with an inbuilt video game."
	elseif i==5 then
	 txt "Dear ___, If I could tell you how much I appreciate the time we spend together, then I would have told you so. But I can't, so I shan't."
	elseif i==6 then
	 txt "Cash runs the whole world. Someday it might take different forms, much better than bartering though."
	elseif i==7 then
	 txt "A train ticket, show this to a ticket collector and you somewhat increase your chances to not lose your train seat."
	elseif i==8 then
	 txt "A train. A big train. With a blue engine. And a happy smile. Sometimes I pretend inanimate objects are people because their design resembles a face."
	elseif i==9 then
	 txt "An oakwood table."
	elseif i==10 then
	 txt "He smells of onions."
	elseif i==11 then
	 txt "He seems happy."
	elseif i==12 then
	 txt "She seems really deeply concerned with her thoughts."
	elseif i==13 then
	 txt "The best friends a man can get."
	elseif i==14 then
	 txt "She seems too old to still be working."
	elseif i==15 then
	 txt "Your classmate, often refers to you as her bestie for god knows why. She's shouting at a bunch of street vendors."
	end
end

--ret 1 for allowing take action, i=object index
function eventBeforeTake(i)
 if i==9 then
	 txd "You can't carry the table around that easily, it's too heavy."
	elseif i==10 or i==11 or i==12 or i==13 or i==14 or i==15 then
	 txt "They probably wouldn't want to be carried around right now."
	else
	 return 1
	end
end

--action after taking object to inventory, i=object index
function eventAfterTake(i)
 if i==9 then
	 txi "Not that heavy actually."
	end
end

--ret 1 for allowing drop action, i=object index
function eventBeforeDrop(i)
 if i==2 then
	 txd "Dropping fish could become an internet trend someday."
	elseif i==3 then
	 txt "Careful! Someone might fall. You might fall."
	else
	 return 1
	end
end

--messages after droping object to room, i=object index
function eventAfterDrop(i)
 if i==4 then
	 txd "It bounces back into your hand ... oops you couldn't catch it though."
	elseif i==5 then
	 txt "The floor was wet, all the ink on the letter has vanished. It is useless now."
		gobjr(5,VOID)
	end
end

--ret 1 when failed to use object, i=object index
function eventUse(i)
 if i==1 and room==12 then
	 txi "The lady on the bench screams with joy"
	 txt "Oh my god, this is exactly what I needed. This even has the evidence. Not only earth but every planet is flat, infact our whole solar system is flat, how else could they show it in a book which is flat! I can now prove to the whole world that the world they have been living in is indeed flat."
	 txt "This conversation confuses you."
	 txt "Listen, she says, you look so confused about everything, if life confuses you, you gotta talk to the old lady by the ticket counter. She's very nice, and wise."
		sobjr(1,VOID)
		points=points +1
	elseif i==1 and room==7 then
	 txi "I already have the book dude, don't give it to me."
	elseif i==1 and room==8 then
	 txi "The dog tears up the book."
		sobjr(1,VOID)
	elseif i==1 and room==10 then
	 txi "You give the book to the man who then proceeds to read it while his hands were wet, the books literally melts before he could read the first paragraph of the first page."
		sobjr(1,VOID)	
	elseif i==1 and room==13 then
	 txi "I don't read books you nerd! shouts your best friend."
	elseif i==1 and room==11 then
	 txi "This is not a good time for me to read this, says the frog."
	elseif i==1 and room==15 then
	 txi "I am too old to benefit from reading this, says the old lady, I also never really liked reading in general."
	elseif i==2 and room==8 then
	 txt "The dog looks curiously at you, then at the fish, then it grabs the fish from you hand and starts chomping on it."
	 txt "The ball she was playing with rolls towards your feet."
	 txt "DO DOGS EVEN EAT FISH? You ask yourself"
	 txt "You now have the ball the dog was playing with."
		sobjr(4,INV)
		sobjr(2,VOID)
	elseif i==2 and room==11 then
	 txt "The frog disregards your offer of a fish."
	elseif i==2 and room==15 then
	 txt "The old lady says she stopped eating fish ever since she saw a movie about a lost fish."
	elseif i==2 and room==12 then
	 txt "It's not even cooked, take it away, says the lady at the bench."
	elseif i==3 and room==7 then
	 txt "You soap up Lory, but there's no water anywhere, he is looking annoyed. You don't have a bucket to bring water from downstairs. Lory cleans himself with a towel."
	elseif i==5 and room==12 then
	 txt "I don't even know you to be honest, says the lady at the bench."
	elseif i==5 and room==15 then
	 txt "You are just not my type, says the old lady."
	elseif i==5 and room==8 then
	 txt "The dog tears up the love letter."
		sobjr(5,VOID)
	elseif i==6 and room==8 then
	 txt "The dog grabs your cash and asks you to stop bothering her anymore."
		sobjr(6,VOID)
	elseif i==3 and room==10 then
	 txt "The man happily takes the soap from you and rubs it over his body."
	 txt "The man acts so thankful, it almost as if you brought joy to his whole life."
		sobjr(3,VOID)
		points=points+1
	elseif i==4 and room==13 then
	 txt "Your friends look happy as ever. They immediately start throwing it around. One of your friend takes out some money from his pocket and gives it to you."
	 txt "You now have some cash to pay for whatever you might want to buy."
		sobjr(4,VOID)
		sobjr(6,INV)
		points=points+1
	elseif i==5 and room==11 then
	 txt "The giant frog takes the letter from you, reads it and turns into a soft spoken human girl."
	 txt "She asks you to not call her a frog the next time you meet with her."
	 txt "She rushes away."
	 txt "The people she was screaming at thank you for your bravery."
		sobjr(5,VOID)
    sobjr(15,VOID)
		points=points+4
	elseif i==6 and room==15 then
	 txt "The old lady gives you a train ticket."
	 txt "Go wherever you want to go, she says. It's a one day pass. But remember, you can only go so far without a foal"
	 txt "A goal? you ask."
	 txt "Do you not know what a foal means? I grew up in a ranch, I miss them so much."
		sobjr(6,VOID)
		sobjr(7,INV)
	elseif i==7 and room==14 then
	 txt "You have now taken the train. But you have to drive it yourself."
		sobjr(8,INV)
	elseif i==8 and room==14 then
	 txt "You can now go roam around the world, or in practical terms your own city. Lots of people need help for things they just can't arrange for themselves. And believe it or not, you have been helping people all this time to reach this end. If not then perhaps you should figure out how to use all the other objects in the simulation ...aagh hmmm ... game."
	 txt "A journey isn't always about the destination, but the people you meet on the way."
	 txt "And I hope you enjoyed this journey."
   txt "The End."
		win()
	else
  return 1
	end
end

--ret 1 when failed to open object, i=object index
function eventOpen(i)
 if i==5  and i==7 then
	 eventExamine(i) --you even can call function to not repeat the same code as in examine
	elseif i==1 then
	 txt "Your flip through the pages of your favourite book of all time."
	elseif i==10 then
	 txt "This is not a slasher movie."
	elseif i==11 then
	 txt "He already seems pretty open."
	elseif i==12 then
	 txt "You perv."
	elseif i==13 then
	 txt "They refuse to open up to you, perhaps such an emotional connection is just not there."
	elseif i==14 then
	 txt "Don't!"
	elseif i==15 then
	 txt "This isn't really a dissection class."
	else
	 return 1
	end
end

--ret 1 when failed to push object, i=object index
function eventPush(i)
 if i==2 then
	 txd "You tried to push the fish but it looked very odd!"
	elseif i==8 then
	 txd "The train won't move."
	elseif i==10 then
	 txd "You can only push a man so far."
	elseif i==11 then
	 txd "This place is too slippery, please don't do it."
	elseif i==12 then
	 txd "Is this a hobby of yours?"
	elseif i==14 then
	 txd "She is sitting behind a counter and hence cannot be pushed."
	elseif i==15 then
	 txd "The frog stares at you for a moment and asks you whats wrong with you. Pushing her again leads to nothing."
	else
	 return 1
	end
end

--ret 1 when failed to talk with object, i=object index
function eventTalk(i)
 if i==2 then
	 txi "You talk with the fish about how confused you feel about the world around you."
	elseif i==7 or i==8 then
	 txi "Yes, this might take you to where you think your destination is."
	elseif i==10 then
	 txi "I am very old school, Lorry tells you."
	elseif i==11 then
	 txi "Even the simplest of things can bring so much joy."
	elseif i==12 then
	 txi "We are going to have the first debate in the society that I run, good arguements with evidence and I will show it to the world."
	elseif i==13 then
	 txi "Go away loser."
	elseif i==14 then
	 txi "Give a man a ticket and he will travel for a day, teach a man to tick it and he will randomly answer his SAT questions."
	elseif i==15 then
	 txi "Can you please not call me a frog!"
	else
	 return 1
	end
end

--what happens when player tries to move from old room to new room
--ret 1 if move is allowed
function eventBeforeMove(ro,rn)
 if ro==2 and rn==3 then
  txd("You are not allowed to move from room "..ro.." to room "..rn)
	else
  return 1
	end
end

--what happens when player moves from old room to new room
function eventAfterMove(ro,rn)
-- txi("You moved from room "..ro.." to room "..rn)
end

--what happens when player waits
function eventWait()
 if room==1 then
	 txt("One of the lights flickered for a second.",1)
	elseif room==2 then
	 txt("Someone is cooking fish somewhere, you can smell it.")
	elseif room==8 then
	 txt("The dog barks at you.")
	elseif room==7 then
	 txt("Lory stares at you.")
	elseif room==14 then
	 txt("You hear a train whistle from a distance")
	end
end

--what happens each turn
function eventTurn()
 txt("Time passes.",2)
end













-- <TILES>
-- 032:0000000000000000000000000000000000070000007770000777770000000000
-- 048:0000000000000000000000000000000000090000009990000999990000000000
-- 064:03737300000000000333330003aaa70003aaa700077777000000000007373700
-- 080:0373730007373700037373000737370003737300073737000373730007373700
-- 096:0000000009999900009990000009000000000000000000000000000000000000
-- 112:0000000007777700007770000007000000000000000000000000000000000000
-- 149:222222222aaaaaaa2aaaaaaa2aa2a2aa2aa2a2aa2aa2a2aa2aa222aa2aaaaaaa
-- 150:222222222aaaaaaa2aaa2aaa2aa222aa2a22222a2aaa2aaa2aaa2aaa2aaaaaaa
-- 151:222222222aaaaaaa2aaaaaaa2aa22aaa2aa2a2aa2aa2a2aa2aa22aaa2aaaaaaa
-- 153:2222222200000000900099000000909000009090000090900000990000000000
-- 154:2222222200000000990990999009009099099090900090909909909900000000
-- 155:2222222200000000099009090909090909900909090909090909090900000000
-- 156:2222222000000000900990000909000090099000090900009009900000000000
-- 165:222222222aaaaaaa2aaa2aaa2aa22aaa2a22222a2aa22aaa2aaa2aaa2aaaaaaa
-- 166:222222222aaaaaaa2aaa2aaa2aaa2aaa2a22222a2aa222aa2aaa2aaa2aaaaaaa
-- 167:222222222aaaaaaa2aaa2aaa2aaa22aa2a22222a2aaa22aa2aaa2aaa2aaaaaaa
-- 169:0000000000000000000099000000909000009900000090000000900000000000
-- 170:0000000000000000909099099090900990909909909009099990990900000000
-- 171:0000000000000000090000000900000099000000090000000900000000000000
-- 209:2222222200000000009090090090990900909099009090090090900900000000
-- 210:2222222200000000000000000000000000000000000000000000000000000000
-- 211:2222222200000000099909990090090900900999009009090090090900000000
-- 212:2222222200000000090909900909090009900990090909000909099000000000
-- 213:2222222200000000000909090009090900090909000909000009990900000000
-- 214:2222222200000000909900000090000090990000909000009099000000000000
-- 215:2222222200000000000009900000090000000990000009000000099000000000
-- 216:2222222200000000909099909090909009009990909090909090909000000000
-- 217:2222222200000000900090909909909090909090900090909000909000000000
-- 218:2222222200000000900909909909090090990990900909009009099000000000
-- 219:2222222200000000000000000000000000000000000000000000000000000000
-- 220:2222222200000000009000900090909000909090009090900009090000000000
-- 221:2222222200000000999090999090900999909009909090099090900900000000
-- 222:2220000000000000900000000000000000000000000000000000000000000000
-- 225:0000000000000000000900900090909000909090009090900009009900000000
-- 226:0000000000000000909990009009000090090000900900009009000000000000
-- 227:0000000000000000099009900909090909090909090909900990090900000000
-- 228:0000000000000000009009900909090909090990090909000090090000000000
-- 229:0000000000000000000090090009090900090909000909090000900900000000
-- 230:0000000000000000900990900909009990099090000900900009909000000000
-- 231:0000000000000000090009090900090999000909090009090900090900000000
-- 232:0000000000000000009090909090909009909090009099900090090000000000
-- 233:0000000000000000990900909009909099090990900900909909009000000000
-- 234:0000000000000000999009000900909009009090090090900900090000000000
-- 235:0000000000000000990090909090909099000900909009009090090000000000
-- 236:0000000000000000009990990009009000090099000900900009009000000000
-- 237:0000000000000000909009099090090990900990909009099099090900000000
-- 241:2222222200000000000000000000000000000000000000000000000000000000
-- 242:2222222200000000000000000000000000000000000000000000000000000000
-- 243:2222222200000000000000000000000000000000000000000000000000000000
-- 244:2222222200000000000000000000000000000000000000000000000000000000
-- 245:2222222200000000000000000000000000000000000000000000000000000000
-- 246:2222222200000000000000000000000000000000000000000000000000000000
-- 247:2222222200000000000000000000000000000000000000000000000000000000
-- 248:2222222200000000000000000000000000000000000000000000000000000000
-- 249:2222222200000000000000000000000000000000000000000000000000000000
-- 250:2222222200000000000000000000000000000000000000000000000000000000
-- 251:2222222200000000000000000000000000000000000000000000000000000000
-- 252:2222222200000000000000000000000000000000000000000000000000000000
-- 253:2222222200000000000000000000000000000000000000000000000000000000
-- 254:2220000000000000000000000000000000000000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:0000000000000000000000000000ffff0000ffff0000ffff0000ffff00000000
-- 001:00000000000000000000000000000000000000000000000000000000000ffff0
-- 002:00000000000000000ffff0000ffff0000ffff0000ffff0000000000000000000
-- 003:000000000ffff0000ffff0000ffff0000ffff000000000000000000000000000
-- 004:00000000000000000000000000000000000000000000000000ffff0000ffff00
-- 005:0000ffff0000ffff0000ffff0000ffff0000000000000000000000000000ffff
-- 006:0ffff0000ffff0000ffff0000ffff00000000000000000000000000000000000
-- 007:000000000000ffff0000ffff0000ffff0000ffff000000000000000000000000
-- 016:0000000000000000000000000ffff0000ffff0000ffff0000ffff00000000000
-- 017:000ffff0000ffff0000ffff00000000000000000000000000000000000000000
-- 018:00000000000000000000000000000000000ffff0000ffff0000ffff0000ffff0
-- 019:00000000000000000000000000000000000ffff0000ffff0000ffff0000ffff0
-- 020:00ffff0000ffff00000000000000000000000000000000000000000000000000
-- 021:0000ffff0000ffff0000ffff000000000000ffff0000ffff0000ffff0000ffff
-- 022:00000000000000000ffff0000ffff0000ffff0000ffff0000000000000000000
-- 023:000000000000000000000000ffff0000ffff0000ffff0000ffff000000000000
-- </SPRITES>

-- <MAP>
-- 000:000000000000000000000000000000000000000000000000000000000000182828282828282828282828282828282828282828282828282828282838132323232323232323232323232323232323232323232323232323232333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939140000000000000000000000000000000000000000000000000000000034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:000000000000000000000000000000000000000000000000000000000000192929292929292929292929292929292929292929292929292929292939152525252525252525252525252525252525252525252525252525252535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:0000000000000000000000000000000000000000000000000000000000001929292929292929292929292929292929292929292929292929292929395969791d2d3d4d5d6d7d8d9dadbdcddd99a9b9c918282828282828282838000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:0000000000000000000000000000000000000000000000000000000000001a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a3a5a6a7a1e2e3e4e5e6e7e8e9eaebecede9aaabaca1a2a2a2a2a2a2a2a2a3a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>


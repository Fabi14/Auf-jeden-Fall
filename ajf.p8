pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
debug = ""
sprites={iso_tree =84,wood = 98,wood_small = 99}
color={text=8}

mode_2d_saw=0
mode_2d_falling=1
mode_iso=2
eq = function (a,b)
    return (a-b)*(a-b) < 0.00001
end

vec = function(x,y)
    local v ={}
    v.x=x or 0
    v.y=y or 0
    mt ={__add = function (a,b)
        return vec(a.x+b.x,a.y+b.y)
    end,
    __sub = function (a,b)
        return vec(a.x-b.x,a.y-b.y)
    end,
    __mul = function (a,b)
        return vec(a.x*b.x,a.y*b.y)
    end,
    __eq = function (a,b)
        return eq(a.x,b.x) and eq(a.y,b.y)
    end
    }
    setmetatable(v,mt)
    return v
end
-->8
--ui
g_ui ={}
create_ui_text = function(name,text,pos)
    local ui = {p=pos}
    ui.text =text
    ui.draw = function (ui)
        print(ui.text,ui.p.x,ui.p.y,color.text)
    end
    g_ui[name]=ui
end

-->8
--iso
create_game_object = function (x,y,sprite,t)
    local go ={p=vec(x,y),s=sprite}
    go.timer = 0
    go.timer_max = t
    go.has_special_animation = false
    go.draw = function (go)
        if go.has_special_animation then 
            go:draw_special_animation()
        else
            spr(go.s+(go.timer>go.timer_max*0.5 and 1 or 0),go.p.x,go.p.y)
        end
    end
    go.update = function (go) end
    return go
end

map_collide = function (p1,p2,p)
    c=function (flag)
        if ((fget(mget(p1.x/8,p1.y/8))&flag)==flag) return true,vec(flr(p1.x/8),flr(p1.y/8)) 
        if((fget(mget(p2.x/8,p2.y/8))&flag)==flag) return true,vec(flr(p2.x/8),flr(p2.y/8))
        return false,p.tree
    end
    is_at_tree,ptree = c(2)
    if c(1) then
        sfx(0)
        return true    
    elseif is_at_tree then
       create_ui_text("p_wait"..p.nr,"waiting for player",p1+vec(8,0)) 
       p.tree = ptree
    --    mode = mode_2d_saw 
       return false
    end 
    create_ui_text("p_wait"..p.nr,"",p1) 
    p.tree = vec(p.nr,p.nr)
    return false
end

len_sqr = function (v)
    return v.x*v.x + v.y*v.y
end

create_player = function (x,y,sprite,t,p_nr)
    local stand_on_wood = function (pos)
        return contains(wood_positions,pos,function(wood,player)
            local dist_square = len_sqr(wood - player)
            return dist_square<64
        end)
    end

    local p =create_game_object(x,y,sprite,t)
    p.nr = p_nr or 0
    p.tree=vec(p_nr,p_nr)
    p.carrys_wood = false
    p.has_special_animation= true
    p.draw_special_animation = function (player)
        -- debug = "draw_special_animation wood?"
        if player.carrys_wood then
            spr(101,player.p.x,player.p.y)
            -- debug = debug.."ja"
        else
            spr(player.s+(player.timer>player.timer_max*0.5 and 1 or 0),player.p.x,player.p.y)
        end
    end

    p.update = function ()
        if(btn(0,p.nr) and not map_collide(p.p + vec(-1,0),p.p + vec(-1,7),p)) p.p.x -=1
        if(btn(1,p.nr) and not map_collide(p.p+ vec(8,0),p.p+ vec(8,7),p)) p.p.x +=1
        if(btn(2,p.nr) and not map_collide(p.p+ vec(0,-1),p.p+ vec(7,-1),p)) p.p.y -=1
        if(btn(3,p.nr) and not map_collide(p.p+ vec(0,8),p.p+ vec(7,8),p)) p.p.y +=1
        if btn(0,p.nr) or btn(1,p.nr) or btn(2,p.nr) or btn(3,p.nr) then
            p.timer+=1
            p.timer = p.timer>p.timer_max and 0 or p.timer
        end

        if stand_on_wood(vec(flr(p.p.x/8),flr(p.p.y/8)))then 
            debug = "on wood"
        end
        
        if btn(4,p.nr) and stand_on_wood(vec(flr(p.p.x/8),flr(p.p.y/8))) and not p.carrys_wood then
            del(wood_positions,vec(flr(p.p.x/8),flr(p.p.y/8)))
            p.carrys_wood = true
        end
    
    end
    return p
end

camera_toplayer = function(player)
    luc = player + vec(-64,-64)
    local x = luc.x>93*8 and luc.x or 93*8
    local x = x<128*8-128 and x or 128*8-128
    local y = luc.y>0 and luc.y or 0
    local y = y<21*8-128 and y or 21*8-128
    camera(flr(x+0.5), flr(y+0.5))
end

-->8
--saw/ tree
create_saw = function()
    local saw = {p=vec(64,108),dx=0}
    saw.draw = function(saw)
        spr(1,saw.p.x - 4*8, saw.p.y - 8, 8, 2)
    end
    saw.update = function (saw)

        mode = mode_2d_falling
        -- if btn(4, 0) and not btn(4, 1) then
        --     if(saw.dx<0) saw.dx*=-1
        --     saw.dx += 0.05
        -- elseif not btn(4, 0) and btn(4, 1) then
        --     if(saw.dx>0) saw.dx*=-1
        --     saw.dx -= 0.05
        -- elseif btn(4, 0) and btn(4, 1) then
        --     saw.dx-=0.3*saw.dx
        -- end
        -- saw.p += vec(saw.dx*0.1,-saw.dx*saw.dx*0.0001)
        -- if saw.p.x < 50 then
        --     saw.p.x =50
        --     saw.dx = 0
        -- elseif saw.p.x >78 then
        --     saw.p.x =78
        --     saw.dx = 0
        -- end
        -- if(saw.p.y <102)mode = mode_2d_falling

    end
    return saw
end

create_tree = function()
    local tree={a=0}
    tree.draw = function (tree)
        rotation_point={x=68,y=103}
        a=tree.a
        for i=0,-20,-0.25 do
            if a<0.125 then
                tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a) + 80*cos(-a+0.25),103+i*sin(-a) +80*sin(-a+0.25) ,17+(20+i)/8,12,0,-1/8/cos(-a))
            else
                tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a) + 80*cos(-a+0.25),103+i*sin(-a) +80*sin(-a+0.25) ,17+(20+i)/8,12,0,-1/8/sin(-a))
            end
        end
        for i=0,12,0.25 do
            if a<0.125 then
            tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a)+ 80*cos(-a+0.25),103+i*sin(-a)+80*sin(-a+0.25),17+(20+i)/8,12,0,-1/8/cos(-a))
            else
                tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a)+ 80*cos(-a+0.25),103+i*sin(-a)+80*sin(-a+0.25),17+(20+i)/8,12,0,-1/8/sin(-a))
            end
        end
        pset(rotation_point.x,rotation_point.y,8)
    end
    return tree
end

-->8
--init
_init = function ()
    srand(time)
    mode = mode_iso
    saw,big_tree = create_saw(),create_tree()

    go_iso ={player = create_player(122*8,5*8,66,20)}
    go_iso.player2 = create_player(123*8,5*8,82,20,1)
    tree_positions = {}
    wood_positions ={}
    -- map x93 y 0  -> 127 / 20
    for y = 0,20 do 
        for x = 93, 127 do 
            if mget(x,y) == 88 then
                add(tree_positions,{p=vec(x,y),empty=false})
            end
        end
    end
end
-->8
--draw
draw = function (o)
    o:draw()
end
update = function (o)
    o:update()
end

foreach_go = function(t,f)
    for k,v in pairs(t) do
        f(v)
    end
end

_draw = function()
    cls(0)
    if mode == mode_iso then
        camera_toplayer(go_iso.player.p + (go_iso.player2.p - go_iso.player.p)*vec(0.5,0.5) )
        map(0,0,0,0)

        foreach(wood_positions,function(v)
            spr(sprites.wood,v.x*8,(v.y-1)*8)
        end) 

        foreach_go(go_iso,draw)
        --iso_tree
        pal(11,0)
        foreach(tree_positions,function(v)
            if(not v.empty) spr(sprites.iso_tree,v.p.x*8,(v.p.y-1)*8)
        end) 
        --iso haus
        spr(192,122*8,2*8)
        spr(193,123*8,2*8)

        foreach_go(g_ui,draw)
        camera(0,0)
    else
        map(0,0,0,0,16,16)
        big_tree:draw() 
        saw:draw()
        if mode == mode_2d_saw then -- runder Abschnitt れもber Sれさge
            spr(62,56,95)
            spr(63,64,95)
        end
    end

    print(debug,0,0,8)
end
-->8
--update
contains = function (tbl,val,f)
    test_fuc = f or function (a,b)
        return a.x == b.x and a.y == b.y
    end
    for _, v in pairs(tbl) do 
       if test_fuc(v,val) then
         return true 
        end
    end
    return false    
end

contains_tree = function (tbl,val)
    for _, v in pairs(tbl) do 
       if v.p.x == val.x and v.p.y == val.y and v.empty ==false then
         return true 
        end
    end
    return false    
end

del_tree = function (val)
    for i, v in pairs(tree_positions) do 
       if v.p.x == val.x and v.p.y == val.y then
            tree_positions[i].empty = true
        end
    end
    return false    
end

player_at_same_tree = function ()
    if contains_tree(tree_positions, go_iso.player.tree) then
        return go_iso.player.tree.x == go_iso.player2.tree.x and go_iso.player.tree.y == go_iso.player2.tree.y
    end
    return false
end

_update = function()
    if mode == mode_2d_saw then
        saw:update()
    elseif mode == mode_iso then
        foreach_go(go_iso,update)
        if player_at_same_tree() then
            del_tree( go_iso.player.tree)
            add(wood_positions,go_iso.player.tree +vec(rnd(4)-3,rnd(4)-3))
            add(wood_positions,go_iso.player.tree +vec(rnd(4)-3,rnd(4)-3))
            add(wood_positions,go_iso.player.tree +vec(rnd(4)-3,rnd(4)-3))
            mode = mode_2d_saw 
        end
    elseif mode == mode_2d_falling then
        if big_tree.a<0.25 then 
            big_tree.a+=0.001
        else
            mode = mode_iso 
            big_tree.a=0
        end
    end
end

__gfx__
00000000000000444440000000000000000000000000000000000000000004444400000000000000000000000000000000000000000000000000000000000000
00000000000004444444400000000000000000000000000000000000000444444440000000000000000000000000000000000000000000000000000000000000
007007000000044444444400006000000006000000006000000006000044444444400000b0000000000000000000000000000000000000000000000000000000
000770000000044400044440066000600066000600066000600066000444400044400000b0000000000000000000000000000000000000000000000000000000
000770000000044400004440666606660666606660666606660666600444000044400000b000b000000000000000000000000000000000000000000000000000
007007000000044400000444666666666666666666666666666666664440000044400000b0b0b0b000b000b00000000000000000000000000000000000000000
000000000000044400000444666666666666666666666666666666664440000044400000b3b0bb300bb303b00000000000000000000000000000000000000000
00000000000004440000044466666666666666666666666666666666444000004440000033333333333333330000000000000000000000000000000000000000
000000000000044400000444666666666666666666666666666666664440000044400000333333333333333300000000aaaa77777777aaaa0000777777770000
000000000000044400000444555655556555565555565555655556554440000044400000333333333333333300000000aaaa77777777aaaa0000777777770000
000000000000044400000444555555555555555555555555555555554440000044400000333333333333333300000000aaaa55777775aaaa0000557777750000
0000000000000444000044400000000000000000000000000000000004440000444000003333b3bb33b3333b00000000aaaa75577775aaaa0000755777750000
000000000000044400044440000000000000000000000000000000000444400044400000b33bbbbbbbbb333b00000000aaaa77777777aaaa0000777777770000
000000000000044444444400000000000000000000000000000000000044444444400000bbbbbbbbbbbbb3bb00000000aaaa77777777aaaa0000777777770000
000000000000044444444000000000000000000000000000000000000004444444400000bbbbbbbbbbbbbbbb00000000aaaa77777777aaaa0000777777770000
000000000000004444400000000000000000000000000000000000000000044444000000bbbbbbbbbbbbbbbb00000000aaaa77577777aaaa0000775777770000
000077777777000000000000000000000000000000000000000000000009090000000557799990000000000000000000aaaa75577777aaaa0000755777770000
000075777777000000000000000000000000999000000000000000000999999900075579999990777779900000000000aaaa55777777aaaa0000557777770000
000075577577000000000000000000000000999999000000000000009990909997755079444997777709999900000000aaaa57777775aaaa0000577777750000
000055777555000000000000000000000999449449990000000000009990000997750779499057700999999900000000aaaa57777755aaaa0000577777550000
000075577555000000000000000000000994499944490000000000000994499097770777755077000999444000000000aaaa77777555aaaa0000777775550000
000077577755000000000000000000000999999999449900000000000099449000070777799000000009900000000000aaaa77777757aaaa0000777777570000
000057777777000000000000000000009999999999999990000000000000949000007799949990000999990900000000aaaa77777777aaaa0000777777770000
000000777700000000000000000000009999944499994499000000000000099900007999999900009949090900000000aaaa77777777aaaa0000777777770000
aaaa77777777aaaa00000000000009944449949999999499999000000099999900007777999700999944990900000000aaaa77777777aaaa0000777777770000
aaaa57777777aaaa00000000000999999999999994999499499999000009949400007577777700099094999000000000aaaa75777777aaaa0000757777770000
aaaa55577775aaaa00000000004449999999999994449999499999000099944497077559757777779090900000000000aaaa75577577aaaa0000755775770000
aaaa77577755aaaa00000000009999999449999999999994494990000099000097779999995577779994999900000000aaaa55777555aaaa0000557775550000
aaaa77777557aaaa00000000000999999944499999999999499990000009499907799944499557009909909900000000aaaa75577555aaaa0000755775550000
aaa5557777777aaa00000000000999999999999444994999999099000099444900779999995570000999999000000000aaaa77577755aaaa0000775777550000
aa777577777755aa00000000000009999999999999999999990000000000040000075977777750009000000900000000aaaa57777777aaaa0000577777770000
aa777777777577aa00000000000000009999999999999999000000000000000000057777777770000000000000000000aaaa77777777aaaa0000777777770000
000000ffff000000000bb000000bb00033333333333000330033333333333300aaa9a9aaaaaaa55779999aaaaaaaaaaa0000bb0000bb00000000bb0000bb0000
00000f0000f0000000b44b0000b44b0033333333300777030400000000000040a9999999aaa7557999999a7777799aaa000b77bbbb77b000000b77bbbb77b000
0000f000000f000000bffb0000bffb0033333343077777703040444444444403999a9a9997755a794449977777a99999000b77777777b000000b77777777b000
0000f000000f00000b9898b00b9898b033333333077777703004000000004003999aaaa99775a779499a577aa9999999000b77777777b000000b77ffff77b000
0000f000000f00000b8989b00b8989b033333333067776603040403333040403a994499a9777a777755a77aaa999444a000b77ffff77b000000b7fbffbf7b000
0000f000000f000000b11b0000b11b0033333333066766603040040000400403aa99449aaaa7a777799aaaaaaaa99aaa000b7fbffbf7b000000b7ffffff7b000
00000f0000f00000000b1b0000b1b00093333333306660033040304004030403aaaa949aaaaa779994999aaaa99999a9000b7ffffff7b0000000b777777b0000
000000ffff0000000000b000000b000033333333330003333040300440030403aaaaa999aaaa79999999aaaa9949a9a90000b777777b0000000bcbbbbbbcb000
0000000ff000000000099000000990000000bbb0300030003040300440030403aa999999aaaa77779997aa99994499a900bbbbbbbbbcb00000bbbccccccbbb00
0000000ff0000000000990000009900000bba9ab004000403040304004030403aaa99494aaaa75777777aaa99a94999a0bfffbcccccbbb0000bffbccccbfffb0
0000000ff000000000c77c0000c77c000b99a9ab404040403040040000400403aa99944497a77559757777779a9a9aaa0bfffbccccbffb00000bbbccccbfffb0
0000000ff000000007c77c7007c77c70b99aa99b004000403040403333040403aa99aaaa97779999995577779994999900bbbbccccbbb00000000b11b1bbbb00
0000000ff000000007c77c7007cccc700b999bb0304030403004000000004003aaa94999a7799944499557aa99a99a9900000b1b11b0000000000bffb5b00000
0000000ff000000009cccc9090cccc9000bbb9b0004000403040444444440403aa994449aa77999999557aaaa999999a00000b5bffb0000000000b55bbbb0000
0000000ff000000000cccc0000cccc000b9b9a9b404040400400000000000040aaaaa4aaaaa7597777775aaa9aaaaaa90000bbbb55bb00000000bbbbb0000000
0000000ff000000000c0c000000c0c00b9a9b9b0004000400033333333333300aaaaaaaaaaa5777777777aaaaaaaaaaa00000000bb0000000000000000000000
0000000ff0000000000000000000bb003b9b5b330000000004000400040304030000000000000000000000000000000000000000000000000000000000000000
0000000fff00000000005750000b57b034b77b990444444404040404000000000000000000000000000000000000000000000000000000000000000000000000
0000000f00ff00000005777500b5755b39b75b930000000004000400444444400000000000000000000000000000000000000000000000000000000000000000
0000000f000ff000007757750bbbf75b33b775333040304004030403000000000000000000000000000000000000000000000000000000000000000000000000
00000ff00000f00007577570b757bfb03b7577b30000000004000400040304030000000000000000000000000000000000000000000000000000000000000000
008ff0000000f0005ff57700b7f57b003bbbbbb30444444404040404000000000000000000000000000000000000000000000000000000000000000000000000
008000000000f0005ff57000b5757b00334333340000000004000400444444400000000000000000000000000000000000000000000000000000000000000000
008000000000888007700000bbbbb000333333933040304000030003000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000aaaaaaaaaaaaaaaaaaaaa9944449949999999499999aaaaa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000aaaa999aaaaaaaaaaaa999999999999994999499499999aa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000aaaa999999aaaaaaaa4449999999999994449999499999aa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000a99944944999aaaaaa999999944999999999999449499aaa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000a99449994449aaaaaaa99999994449999999999949999aaa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000a9999999994499aaaaa999999999999444994999999a99aa0000000000000000000000000000000000000000000000000000000000000000
0000000000000000999999999999999aaaaaa999999999999999999999aaaaaa0000000000000000000000000000000000000000000000000000000000000000
00000000000000009999944499994499aaaaaaaa9999999999999999aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000
9888889999999999999aaaa9999999990000000000000000000000000000000000b0000b000b00bb000bb0bbb0bbbb0bbbbbb000000000000000000000000000
99889999999999999999aa9999999999007000007000000000000700000000000b7b00b7b0b7bb77b0b77b777b7577b777777b00000000000000000000000000
9444944949949499499444494944499400000000000000000000000000000000b777bb777b777b777b777b7777b777b77bbb77b0000000000000000000000000
4444444444544445444445444454445400000070000000000000000000000000b777bb777b777b5777777bbb57bbbbb77bbb75b0000000000000000000000000
4444544444444444445444444444444400000000000000000000000000000000b775bb777b775b7777777bbb7b7bb0b777777b00000000000000000000000000
4444444444445444444444444444444400000000000000000000070000000000b757bb777b757b77b7b77b777b777bb5777b0000000000000000000000000000
4544444444444444444454444454444407000000000070000070000000000000b777bb777b777b77bbb77bbb77bb00b77b77b000000000000000000000000000
4444444444444444444444444444445400000000000000000000000000000000b57777b77b777b77b0b57bbb57bbbb777bb77b00000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa11111111111111111111111100000000b757777b77777b77b0b77b7777b777b77b0b77b0000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa111111111111111111111111000000000b7777b77777bb77b0b77b777b7775b7b000b7b0000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1611111111111111111161110000000000bbbb0bbbbb00bb000bb0bbb0bbbb0b00000b00000000000000000000000000
aaaaaa9aaaaaaaaaaaaaa9aaaaaa9aaa111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000
aaaaaa9aaaaaa8aaaaaaa99aaaa99aaa11111111116111111116111100000000000bbbbbbbb0bb00bbbbbb0bbbbbbb0000bb0000000000000000000000000000
aaa9aa9aa9aa788aa444aa9a99a9aaaa1111161111111111111111110000000000b4666666bb77bb777777b777577bb00b99b000000000000000000000000000
aa99aa9aa99aa7aaaa7aaa9aa9a9aa9a1111111111111111111111110000000000b46bbbb66b757b77bbb75b77777b9bb999b000000000000000000000000000
aa9aaa9aaa9aa7aaaa7aaa9aa9a9aa9a1111111111111111111111110000000000b46b00b66bb77b77bbb57b77bbb999999b0000000000000000000000000000
0000066666600000aaaaaaaaeeeeeeee2222222222222222222222220000000000b46bbb66bbb77b777777bb77b00b7757b00000000000000000000000000000
0006666666666000aaaaaaaaeeeeeeee2222226222222222222222220000000000b466666bbbb77b7777bb0b75b000b77b000000000000000000000000000000
0066666666666600aaaaaaaaeeeeeeee2222222222222222222222220000000000b44bbbb77bb75b5577b00b77b000b77b000000000000000000000000000000
0666666666556660aaaaaaaaeeeeeeee2222222222222222222222220000000000b44b00b777757b77b75b0b57b000b75b000000000000000000000000000000
0666666665665660aaaaaaaaeeeeeeee2222222222222222222222220000000000b44b00b57bb77b77bb77bb77b000b77b000000000000000000000000000000
6666666665665666aaaaaaaaeeeeeeee2222222222222222262222220000000000b44b00b75bb77b77b0b77b77b000b57b000000000000000000000000000000
6665556666556666aaaaaaaaeeeeeeee2222222222262222222222220000000000b44b00b77bb77b77b00b7b77b000b77b000000000000000000000000000000
6656665666666666aaaaaaaaeeeeeeee22222222222222222222222200000000000bb0000bb00bb0bb0000b0bb00000bb0000000000000000000000000000000
66566656666666669999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66566656666666669999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66655566666666669999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666666666666609999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666666666666609999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666656666009999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066666565660009999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666656000009999999922222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000b0000000000000000000000000003333999443443333003393330000000000000000000000000000000000000000000000000000000000000000
00000000000b6b000000056000005000000000003333333933333300990993330000000000000000000000000000000000000000000000000000000000000000
00bbbbbbbbbb5bb00000055000555550000050003999333333330099a90333830000000000000000000000000000000000000000000000000000000000000000
0b44bb44444b6b4b00000000005665000005600033333433330099a99a9033730000000000000000000000000000000000000000000000000000000000000000
b44b7cb4444b6b4b000000000055660000056000383334330099a99a9a9033330000000000000000000000000000000000000000000000000000000000000000
b44bccb44444b44b0006500000066000005600003733000099a99a9a99a903330000000000000000000000000000000000000000000000000000000000000000
b44444444444444b00655000000000000560000033300099a99a9a99a9a903340000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb000000000000000005600000333044099a9a99a9a99a90330000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000330444099a99a9a99a9a90330000000000000000000000000000000000000000000000000000000000000000
08800880088008800000000000000000000000003300444099a9a99a9a9000330000000000000000000000000000000000000000000000000000000000000000
0807c007c007c0800000000000000000000000003304044099a99a9a500440330000000000000000000000000000000000000000000000000000000000000000
080cc00cc00cc08000000000000000000000000093044044099a9a95654440990000000000000000000000000000000000000000000000000000000000000000
080000000000008000000000000000000000000099040404099a9056665460390000000000000000000000000000000000000000000000000000000000000000
00444444444444000000000000000000000000003300504009900456565660330000000000000000000000000000000000000000000000000000000000000000
04444444444444400000000000000000000000003300950400044456565660330000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003330550404444456565003340000000000000000000000000000000000000000000000000000000000000000
0804088888804080000000000000000000000000333a050404446656665333370000000000000000000000000000000000000000000000000000000000000000
080408800880408000000000000000000000000093aaa00604666665653333330000000000000000000000000000000000000000000000000000000000000000
080408055080408000000000000000000000000093aaaa060666600353333aa30000000000000000000000000000000000000000000000000000000000000000
080408095080408000000000000000000000000043a9a330066003333aaaaaaa0000000000000000000000000000000000000000000000000000000000000000
080408055080408000000000000000000000000043aaaa330003333aaaaaaa9a0000000000000000000000000000000000000000000000000000000000000000
0004000000004000000000000000000000000000443aaaaaaaaaaaaaa9aaaaaa0000000000000000000000000000000000000000000000000000000000000000
04444444444444400000000000000000000000009433aa9aaaaaa9aaaaaaa9aa0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000099443333333aaaaaa333aaaa0000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000001010100000000000001010100000000010001000000040402010101000000000101010000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000010100000001010100000000000000000101000000010100000000000000000000000000000000000000000000000000
__map__
b584b5b5b5b5b584b5b5b586b5b5b5b500000000000000000084b5b5b5b5b5b5b5b5b5b5b586b5b5b5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004545454545454545454545454545454545454545454545454545454545454545454545
85b5b5b5b586b5b5b585a0a1b584b5b5000000000000000000b5b586b585b5b5b585b5b5b5b5b5b5b5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444445444444444444444444444444444444444444444445
b5b5b585b5b5b495b4b5b0b1b5b5b5b5000000000000000000b5b4b4b4b4b4b4b4b4b4b4b4b4b4b485000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444544444444444444444444444444444444444444444444444444444445
b584b5b5b4b494b4b496b4b5b584b5b5000024250000000000b4b4b3b3b3b3b3b3b3b3b3b3b3b3b4b4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444454544444444444444444444444444444444444444444444d0d144444445
b5b5b5b495b3b3a4b3b3b494b4b586b5003334353600000000b3b3b3a3a3a3a3a3a3a3a3a3a3b3b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444444444464444445454444444444e0e144444445
b5b4b496b3a5a5b3b3a4b3b3b495b4b5b52728292a00000000b3a3a3a3b2b2b2b2b2b2b2b2a3a3a3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444445444444444444454545444444444444444444444445
9594b3b3b3a3a3a3a3a3a3b3b3a594b4003738393a00000000a3a3b2b2b2b2b2b2b2b2b2b2b2b2a3a3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444464444444444444444444444444444444444444444444444444444445
b4b3a4a3a3a3a3a3a3a3a3a3a3b3b3b400003e1f0000000000b2b2b2b2b2a2a2a2a2a2a2b2b2b2b2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444444644444444444444464444444444444444445
b3a3a3a3a3b2b2b2b2b2b2a3a3a3a3b300002e2f0000000000b2b2b2a2a2a2a2a2a27273a2a2b2b2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444446444444464444444444444444444444545444444444444444444444445
a3a3a3b2b2b2b2b2b2b2b2b2b2a3a3a300001e3f0000000000b2a2a27273a2a2a274757677a2a2a2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444464444444444444444444444444454444444445444444444444444444444445
a3b2b2b2b2b2a2a2a2a2b2b2b2b2b2a300001e2f0000000000a2a274757677a2a2a22c2da2a2a2a2a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444445454444444444444444454444444445444444444444444444444445
b2b2b2b2a2a2a2a2a2a2a2a2b2b2b2b200003e1f0000000000a2a2a22c2da2a2a248494a4ba2a2a2a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444545444444444444444444444444444444444444446444644464444445
b2b2a2a2a2a2a2a2a2a2a2a2a2a2b2b200002e2f0000000000a2a248494a4ba2a2a22c3da2a2a2a2a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544454444444444444444644444444444444444444444444444444444444444444445
a2a2a2a2a2909330319392a2a2a2a2a200003e3f0000000000a2a2a23c3da2a2a2a23c3da2a2a2a2a2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544454444444444444444444444444444444444444444444464446444644464444445
9390919091838082838082929091939000000000000000000093909130319092919030319290919390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444465656565656565656565656565656565656545
8180838280838383838383828082808300000000000000000081808382808383838383838280828083000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544c5c6c7444444444445454444444444444444444444444444444444444444444445
4747474747474747474747474747474700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544d5d6d7444444444445454544444444444444444444644444444444444444444445
474c4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544e5e6e7444444444444456444444444644444644444444444444444446444444445
475c464646464646464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444444444444444444444444446444444444444445
475c464646464646464646464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004544444444444444444444444444444444444444444444444444444444444444444445
475c464646465846464747464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004545454545454545454545454545454545454545454545454545454545454545454545
475c464646464647474746464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c464646464646464646464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c464658464646464646465846595a5b460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c464646464646474746464646464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c464647464646464746464646464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c464647464646464746464646464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
475c000000000000000000000000000000000000000000000000000000000047470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
476c6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d6d47474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747470000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474700000000000000000000000000000000000000000000000000000000
__sfx__
0100000027650236501f6501b65016650126500f6500c6500a6500865006650056500365001650006500075000000000000000000000020000000000000000000000000000000000000000000000000000000000
090a0000103530000010353000002d653000000000010353103530000010353000002d653000000000010353103530000010353000002d653000000000010353103531035310353103532d653000000000010353
510a000026251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a2512625126251262512625126211000001a2511a251
010a000000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e350
311900000025300000002003560000000000000025300000002530000000000356000000000000000000000000253000000000035633000000000000253000000025300000000003563300000000000000000000
c91900002821029211282212922128231292312822129211282112921128221292212821129211282112921128211292012821429201000000000000000000002820029200282142920100000000000000000000
c9190000302103221130221322213023132231302213221130211322113022132221302113221130201322012f504000000000000000000000000032200000000000000000000000000000000000000000000000
791000001f3561832018320000201d3561a3201a3201a02000000000000000000000000000000000000000001f3561d3201d320050201d3561c3201c320040201f35618320183200002000000000000000000000
791000001f356183201832000020113561a3201a3201a02010300153001530015000000000000000000000001f3561d3201d320050201d3561c3201c320040201035615320153201502013356113201132011020
91100000285142f742285422d5422d5302d5202d5102d500001000000000000307003070030700307000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d10000025552255402a5522a54025552255402c5522c5522c5422c5322c5222c5122c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d10000025552255402a5522a54025552255402c5522c5502a5522a54025550255402553025522255222551200000000000000000000000000000000000000000000000000000000000000000000000000000000
1d10000025552255402c5522c54026552265402d5522d5522d5422d5322d5222d5122c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d1000002f5522f5402d5522d54028552285402d5522d5502c5422c5322c5222c5222c5122c5122c5152c50500000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000015251213312d4212d22015220152201521500000142501423014220142150000000000132501323013220132150000000000122501223012220122150000000000000000000011250112301122011215
010800000000000000000000000015350153301532015320153201531515350153301532015315000000000000000000001535015330153201531500000000001535015330153201531500000000000000000000
00100010112501123011220002001025010230002000e2500e2300e2200e2100e2100e2220e2220e2320e25200000000000000000000000000000000000001000000000000000000000000000000000000000000
011000100000018250182301822000200172501723015250152301522015210152101522015220152401525000000000000000000000000000000000000000000000000000000000000000000000000000000000
0108000000000000001c3501c3501c3301c3301c3201c32000000003001c3501c3501c3501c3501c330000001c3201c3201c3101c3101c3101c3101c3201c3201c3201c3201c3401c3401c3501c3500000000000
0108000000000000001c3501c3501c3301c3301c3201c32000000003001c3501c3501c3501c3501c3301c33000000000001c3201c3201c3101c3101c3401c3401c3501c3501c3601c36000000000000000000000
010800001c653000003463200000346003460034633000001c653000000000000000346330000000000000001c653000003464400000346250000034632000021c65300000346330000034632000003465300000
__music__
03 01020344
01 04054344
02 04064344
00 41070944
00 41080944
01 410a0e44
02 410b0e44
00 410c4344
02 410d4344
01 0e0f1314
02 10111214


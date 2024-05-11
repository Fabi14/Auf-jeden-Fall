pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
debug = ""
sprites={iso_tree =72,wood = 100,wood_small = 101}
color={text=8}

mode_2d_saw=0
mode_2d_falling=1
mode_iso=2
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
        return a.x==b.x and a.y==b.y
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
    go.draw = function (go)
        spr(go.s+(go.timer>go.timer_max*0.5 and 1 or 0),go.p.x,go.p.y)
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
    debug = ptree
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

create_player = function (x,y,sprite,t,p_nr)
    local p =create_game_object(x,y,sprite,t)
    p.nr = p_nr or 0
    p.tree=vec(p_nr,p_nr)
    p.update = function ()
        if(btn(0,p.nr)and not map_collide(p.p + vec(-1,0),p.p + vec(-1,7),p)) p.p.x -=1
        if(btn(1,p.nr) and not map_collide(p.p+ vec(8,0),p.p+ vec(8,7),p)) p.p.x +=1
        if(btn(2,p.nr) and not map_collide(p.p+ vec(0,-1),p.p+ vec(7,-1),p)) p.p.y -=1
        if(btn(3,p.nr) and not map_collide(p.p+ vec(0,8),p.p+ vec(7,8),p)) p.p.y +=1
        if btn(0,p.nr) or btn(1,p.nr) or btn(2,p.nr) or btn(3,p.nr) then
            p.timer+=1
            p.timer = p.timer>p.timer_max and 0 or p.timer
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
        return

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
    saw,tree = create_saw(),create_tree()

    go_iso ={player = create_player(122*8,5*8,68,20)}
    go_iso.player2 = create_player(123*8,5*8,84,20,1)
    tree_positions = {}
    wood_positions ={}
    -- map x93 y 0  -> 127 / 20
    for y = 0,20 do 
        for x = 93, 127 do 
            if mget(x,y) == 88 then
                add(tree_positions,vec(x,y))
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
        foreach_go(go_iso,draw)
        --iso_tree
        pal(11,0)
        foreach(tree_positions,function(v)
            spr(sprites.iso_tree,v.x*8,(v.y-1)*8)
        end) 
        foreach(wood_positions,function(v)
            spr(sprites.wood,v.x*8,(v.y-1)*8)
        end) 
        --iso haus
        spr(192,122*8,2*8)
        spr(193,123*8,2*8)

        foreach_go(g_ui,draw)
        camera(0,0)
    else
        map(0,0,0,0,16,16)
        tree:draw() 
        saw:draw()
        if mode == mode_2d_saw then -- runder Abschnitt über Säge
            spr(62,56,95)
            spr(63,64,95)
        end
    end


    -- print(debug,0,0,8)
end
-->8
--update
contains = function (tbl,val)
    for _, v in pairs(tbl) do 
       if v.x == val.x and v.y == val.y then return true end
    end
    return false    
end

player_at_same_tree = function ()
    if contains(tree_positions, go_iso.player.tree) then
        return go_iso.player.tree.x == go_iso.player2.tree.x and go_iso.player.tree.y == go_iso.player2.tree.y
    end
    return false
end

_update = function()
    if mode == mode_2d_saw then
        saw:update()
    elseif mode == mode_2d_falling then
        if tree.a<0.25 then 
            tree.a+=0.001
        else
            mode = mode_iso 
            tree.a=0
        end
    elseif mode == mode_iso then
        foreach_go(go_iso,update)
        if player_at_same_tree() then
           mode = mode_2d_saw 
            del(tree_positions, go_iso.player.tree)
            add(wood_positions,go_iso.player.tree +vec(rnd(6)-3,rnd(6)-3))
            add(wood_positions,go_iso.player.tree +vec(rnd(6)-3,rnd(6)-3))
            add(wood_positions,go_iso.player.tree +vec(rnd(6)-3,rnd(6)-3))
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
0000000000000444000004446666666666666666666666666666666644400000444000003333333333333333000000000000777777770000aaaa77777777aaaa
0000000000000444000004445556555565555655555655556555565544400000444000003333333333333333000000000000777777770000aaaa57777777aaaa
0000000000000444000004445555555555555555555555555555555544400000444000003333333333333333000000000000557777750000aaaa55577775aaaa
0000000000000444000044400000000000000000000000000000000004440000444000003333b3bb33b3333b000000000000755777750000aaaa77577755aaaa
000000000000044400044440000000000000000000000000000000000444400044400000b33bbbbbbbbb333b000000000000777777770000aaaa77777557aaaa
000000000000044444444400000000000000000000000000000000000044444444400000bbbbbbbbbbbbb3bb000000000000777777770000aaa5557777777aaa
000000000000044444444000000000000000000000000000000000000004444444400000bbbbbbbbbbbbbbbb000000000000777777770000aa777577777755aa
000000000000004444400000000000000000000000000000000000000000044444000000bbbbbbbbbbbbbbbb000000000000775777770000aa777777777577aa
00000000000000000000000000000000000000000000000000000000000909000000055779999000000000000000000000007557777700000000000000000000
00000000000000000000000000000000000099900000000000000000099999990007557999999077777990000000000000005577777700000000000000000000
00000000000000000000000000000000000099999900000000000000999090999775507944499777770999990000000000005777777500000000000000000000
00000000000000000000000000000000099944944999000000000000999000099775077949905770099999990000000000005777775500000000000000000000
00000000000000000000000000000000099449994449000000000000099449909777077775507700099944400000000000007777755500000000000000000000
00000000000000000000000000000000099999999944990000000000009944900007077779900000000990000000000000007777775700000000000000000000
00000000000000000000000000000000999999999999999000000000000094900000779994999000099999090000000000007777777700000000000000000000
00000000000000000000000000000000999994449999449900000000000009990000799999990000994909090000000000007777777700000000000000000000
00000000000000000000000000000994444994999999949999900000009999990000777799970099994499090000000000007777777700000000777777770000
00000000000000000000000000099999999999999499949949999900000994940000757777770009909499900000000000007577777700000000757777770000
00000000000000000000000000444999999999999444999949999900009994449707755975777777909090000000000000007557757700000000755775770000
00000000000000000000000000999999944999999999999449499000009900009777999999557777999499990000000000005577755500000000557775550000
00000000000000000000000000099999994449999999999949999000000949990779994449955700990990990000000000007557755500000000755775550000
00000000000000000000000000099999999999944499499999909900009944490077999999557000099999900000000000007757775500000000775777550000
00000000000000000000000000000999999999999999999999000000000004000007597777775000900000090000000000005777777700000000577777770000
00000000000000000000000000000000999999999999999900000000000000000005777777777000000000000000000000007777777700000000007777000000
000000ffff0000000000000000000000000990000004400033399333333000330000bbb000000000000000000000000000333333300030003333330033333333
00000f0000f0000000000000000000000009900000099000333333393007770300bba9ab00000000000000000000000004000000004000400000004033333333
0000f000000f00000000000000000000008888000008800093333334077777700b99a9ab00000000000000000000000030404444404040404444440333333333
0000f000000f0000000000000000000008888880008888003333399307777770b99aa99b00000000000000000000000030040000004000400000400333333333
0000f000000f00000000000000000000088888800888888033933343067776600b999bb000000000000000000000000030404033304030403304040333333333
0000f000000f000000000000000000000988889009088890334933430667666000bbb9b000000000000000000000000030400400004000400040040333333333
00000f0000f00000000000000000000000cccc00000ccc0093493393306660030b9b9a9b00000000000000000000000030403040404040400403040333333333
000000ffff000000000000000000000000c0c000000c0c00939a393333000333b9a9b9b000000000000000000000000030403004004000404003040333333333
0000000ff00000000000000000000000000990000009900000000000000000003b9b5b3300000000000000000000000000000000333333330403040333333333
0000000ff000000000000000000000000009900000099000000000000000000034b77b9900000000000000000000000004444444333333330000000033333333
0000000ff0000000000000000000000000c77c0000c77c00000000000000000039b75b9300000000000000000000000000000000333333334444444033333333
0000000ff0000000000000000000000007c77c7007c77c70000000000000000033b7753300000000000000000000000030403040333333330000000033333333
0000000ff0000000000000000000000007c77c7007cccc7000000000000000003b7577b300000000000000000000000000000000333333330403040333333333
0000000ff0000000000000000000000009cccc9090cccc9000000000000000003bbbbbb300000000000000000000000004444444333333330000000033333333
0000000ff0000000000000000000000000cccc0000cccc0000000000000000003343333400000000000000000000000000000000333333334444444033333333
0000000ff0000000000000000000000000c0c000000c0c0000000000000000003333339300000000000000000000000030403040333333330000000033333333
0000000ff00000000000000000000000000000000000bb0000000000000000000000000000000000000000000000000030403004040004004003040333333333
0000000fff000000000000000000000000005750000b57b000000000000000000000000000000000000000000000000030403040040404040403040333333333
0000000f00ff000000000000000000000005777500b5755b00000000000000000000000000000000000000000000000030400400040004000040040333333333
0000000f000ff0000000000000000000007757750bbbf75b00000000000000000000000000000000000000000000000030404033040304033304040333333333
00000ff00000f000000000000000000007577570b757bfb000000000000000000000000000000000000000000000000030040000040004000000400333333333
008ff0000000f00000000000000000005ff57700b7f57b0000000000000000000000000000000000000000000000000030404444040404044444040333333333
008000000000f00000000000000000005ff57000b5757b0000000000000000000000000000000000000000000000000004000000040004000000004033333333
0080000000008880000000000000000007700000bbbbb00000000000000000000000000000000000000000000000000000333333000300033333330033333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333333333333
9888889999999999999aaaa99999999900000000aaaaaaaaeeeeeeee111111110000000000000000000000000000000000000000000000000000000000000000
99889999999999999999aa999999999900000000aaaaaaaaeeeeeeee111111110070000070000000000007000000000000000000000000000000000000000000
9444944949949499499444494944499400000000aaaaaaaaeeeeeeee111111110000000000000000000000000000000000000000000000000000000000000000
4444444444544445444445444454445400000000aaaaaaaaeeeeeeee111111110000007000000000000000000000000000000000000000000000000000000000
4444544444444444445444444444444400000000aaaaaaaaeeeeeeee111111110000000000000000000000000000000000000000000000000000000000000000
4444444444445444444444444444444400000000aaaaaaaaeeeeeeee111111110000000000000000000007000000000000000000000000000000000000000000
4544444444444444444454444454444400000000aaaaaaaaeeeeeeee111111110700000000007000007000000000000000000000000000000000000000000000
4444444444444444444444444444445400000000aaaaaaaaeeeeeeee111111110000000000000000000000000000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000009999999922222222000000001111111111111111111111110000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000009999999922222222000000001111111111111111111111110000000000000000000000000000000000000000
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000009999999922222222000000001611111111111111111161110000000000000000000000000000000000000000
aaaaaa9aaaaaaaaaaaaaa9aaaaaa9aaa000000009999999922222222000000001111111111111111111111110000000000000000000000000000000000000000
aaaaaa9aaaaaa8aaaaaaa99aaaa99aaa000000009999999922222222000000001111111111611111111611110000000000000000000000000000000000000000
aaa9aa9aa9aa788aa444aa9a99a9aaaa000000009999999922222222000000001111161111111111111111110000000000000000000000000000000000000000
aa99aa9aa99aa7aaaa7aaa9aa9a9aa9a000000009999999922222222000000001111111111111111111111110000000000000000000000000000000000000000
aa9aaa9aaa9aa7aaaa7aaa9aa9a9aa9a000000009999999922222222000000001111111111111111111111110000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066666600000000000002222222222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000000006666666666000000000002222226222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000000066666666666600000000002222222222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000000666666666556660000000002222222222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000000666666665665660000000002222222222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000006666666665665666000000002222222222222222262222220000000000000000000000000000000000000000
00000000000000000000000000000000000000006665556666556666000000002222222222262222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000006656665666666666000000002222222222222222222222220000000000000000000000000000000000000000
00000000000000000000000000000000000000006656665666666666000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006656665666666666000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006665556666666666000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000666666666666660000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000666666666666660000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000066666665666600000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006666656566000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000066665600000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000001010100000000000000000002010101010001000000000004040000000000000101010000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000010100000001010100000000000000000101000000000100000000000000000000000000000000000000000000000000
__map__
889789978a978897978997889788978900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004747474747474747474747474747474747474747474747474747474747474747474747
979788979797978997889797a5a6979700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464647464646464646464646464646464646464646464647
8a9797978a87878787878797b5b6978a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464646464646464646464647
9788978787878798878787879a978a9700002425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464646464646d0d146464647
979987879a9696969696a8879987879700333435360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464658464647474646464646e0e146464647
878798a896a8969696aa9696a8878799002728292a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464647464646464646474747464646464646464646464647
87969696968686868686869696a99687003738393a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464658464646464646464646464646464646464646464646464646464647
aa96a88686868686868686868696969600003c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646584646464646464658464646464646464647
9686868686959595959595868686869600002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646465846464658464646464646464646464747464646464646464646464647
8686869595959595959595959586868600001c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464658464646464646464646464646474646464647464646464646464646464647
8695959595958585858595959595958600001c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646474646464647464646464646464646464647
9595959585858585858585859595959500003c1d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464646465846584658464647
9595858585858585858585858585959500002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646584646464646464646464646464646464646464646464647
858585858590931e1f9392858585858500003c3d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464658465846584658464647
939091909183808283808292909193900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000474646464646464646464646464646464d4d4d4d4d4d4d4d6d6d6d6d6d6d6d6d6d6d47
8180838280838383838383828082808300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746c5c6c7464646464646464646464646464646464646464646464646464646464647
4747474747474747474747474747474700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746d5d6d7464646464646464646464646464646464646584646464646464646464647
474c4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746e5e6e7464646464646465846464646584646584646464646464646465846464647
475c464646464646464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464646465846464646464647
475c464646464646464646464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004746464646464646464646464646464646464646464646464646464646464646464647
475c464646465846464747464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004747474747474747474747474747474747474747474747474747474747474747474747
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
510a000026251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a25126251262511a2511a2512625126251262512625100000000001a2511a251
010a000000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e35000000000000e3540e350
311900000025300000002003560000000000000025300000002530000000000356000000000000000000000000253000000000035633000000000000253000000025300000000003563300000000000000000000
c91900002821029211282212922128231292312822129211282112921128221292212821129211282112921128211292012821429201000000000000000000002820029200282142920100000000000000000000
c9190000302103221130221322213023132231302213221130211322113022132221302113221130201322012f504000000000000000000000000032200000000000000000000000000000000000000000000000
791000001f3561832018320000201d3561a3201a3201a02000000000000000000000000000000000000000001f3561d3201d320050201d3561c3201c320040201f35618320183200002000000000000000000000
791000001f356183201832000020113561a3201a3201a02010300153001530015000000000000000000000001f3561d3201d320050201d3561c3201c320040201035615320153201502013356113201132011020
911000003075230732307323071200000000000000000000000000000000000000000000000000000000000030700307003070030700000000000000000000000000000000000000000000000000000000000000
1d10000025552255402a5522a54025552255402c5522c5522c5422c5322c5222c5122c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1d10000025552255402a5522a54025552255402c5522c5502a5522a54025550255402553025522255222551200000000000000000000000000000000000000000000000000000000000000000000000000000000
1d10000025552255402a5522a54025552255402c5522c5522c5422c5322c5222c5122c50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 01020344
01 04054344
02 04064344
00 41070944
00 41080944
00 41024344


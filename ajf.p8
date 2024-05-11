pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
debug = ""
sprites={iso_tree =72}
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
        return (fget(mget(p1.x/8,p1.y/8))&flag)==flag,vec(flr(p1.x/8),flr(p1.y/8)) or(fget(mget(p2.x/8,p2.y/8))&flag)==flag,vec(flr(p2.x/8),flr(p2.y/8))
    end
    is_at_tree,p.tree = c(2)
    debug = p.tree
    if c(1) then
        return true    
    elseif is_at_tree then
       create_ui_text("p_wait"..p.nr,"waiting for player",p1+vec(8,0)) 
    --    mode = mode_2d_saw 
       return false
    end 
    create_ui_text("p_wait"..p.nr,"",p1) 
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

camera_toPlayer = function(player)
    luc = player.p + vec(-64,-64)
    camera(luc.x>0 and luc.x or 0 ,luc.y>17*8 and luc.y or 17*8)
end


-->8
--saw/ tree
create_saw = function()
    local saw = {p=vec(64,108),dx=0}
    saw.draw = function(saw)
        spr(1,saw.p.x - 4*8, saw.p.y - 8, 8, 2)
    end
    saw.update = function (saw)
        if btn(4, 0) and not btn(4, 1) then
            if(saw.dx<0) saw.dx*=-1
            saw.dx += 0.05
        elseif not btn(4, 0) and btn(4, 1) then
            if(saw.dx>0) saw.dx*=-1
            saw.dx -= 0.05
        elseif btn(4, 0) and btn(4, 1) then
            saw.dx-=0.3*saw.dx
        end
        saw.p += vec(saw.dx*0.1,-saw.dx*saw.dx*0.0001)
        if saw.p.x < 50 then
            saw.p.x =50
            saw.dx = 0
        elseif saw.p.x >78 then
            saw.p.x =78
            saw.dx = 0
        end
        if(saw.p.y <102)mode = mode_2d_falling

    end
    return saw
end

create_tree = function ()
    local tree={a=0}
    tree.draw = function (tree)
        rotation_point={x=68,y=103}
        a=tree.a
        for i=0,-20,-0.25 do
            tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a) + 80*cos(-a+0.25),103+i*sin(-a) +80*sin(-a+0.25) ,17+(20+i)/8,12,0,-1/8)
        end
        for i=0,12,0.25 do
            tline(68+i*cos(-a),103+i*sin(-a),68+i*cos(-a)+ 80*cos(-a+0.25),103+i*sin(-a)+80*sin(-a+0.25),17+(20+i)/8,12,0,-1/8)
        end
        pset(rotation_point.x,rotation_point.y,8)
    end
    return tree
end

-->8
--init
_init = function ()
    mode = mode_iso
    saw,tree = create_saw(),create_tree()

    go_iso ={player = create_player(5*8,20*8,68,20)}
    go_iso.player2 = create_player(7*8,20*8,84,20,1)
    tree_positions ={vec(4,22),vec(6,19),vec(12,22)}
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
        camera_toPlayer(go_iso.player)
        map(0,0,0,0)
        foreach_go(go_iso,draw)
        --iso_tree
        foreach(tree_positions,function(v)
            spr(sprites.iso_tree,v.x*8,v.y*8)
        end) 
        foreach_go(g_ui,draw)
        camera(0,0)
    else
        map(0,0,0,0,16,16)
        tree:draw()
        saw:draw()
        if mode == mode_2d_saw then
            circfill(63,95,5,4)
        end
    end


    print(debug,0,0,8)
end
-->8
--update

_update = function()
    if mode == mode_2d_saw then
        saw:update()
    elseif mode == mode_2d_falling then
        if( tree.a<0.25)tree.a+=0.001
    elseif mode == mode_iso then
        foreach_go(go_iso,update)
        debug = go_iso.player.tree.x 
        debug =debug .. go_iso.player2.tree.x 
        if go_iso.player.tree == go_iso.player2.tree then
           mode = mode_2d_saw 
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
00000000000004440000044466666666666666666666666666666666444000004440000033333333333333330000000000000000000000000000000000000000
00000000000004440000044455565555655556555556555565555655444000004440000033333333333333330000000000000000000000000000000000000000
00000000000004440000044455555555555555555555555555555555444000004440000033333333333333330000000000000000000000000000000000000000
0000000000000444000044400000000000000000000000000000000004440000444000003333b3bb33b3333b0000000000000000000000000000000000000000
000000000000044400044440000000000000000000000000000000000444400044400000b33bbbbbbbbb333b0000000000000000000000000000000000000000
000000000000044444444400000000000000000000000000000000000044444444400000bbbbbbbbbbbbb3bb0000000000000000000000000000000000000000
000000000000044444444000000000000000000000000000000000000004444444400000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000
000000000000004444400000000000000000000000000000000000000000044444000000bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000
00000000000000000000000000000000000000033000000000000000000000000000333333330000000000000000000000044444444440000000000000000000
00000000000000000000000000000000000000033000000000000000000000000003333333333000000000000000000000044444444440000000000000000000
00000000000000000000000000000000000000333300000000000000000000000033333333333300000000000000000000044444444440000000000000000000
00000000000000000000000000000000000000333300000000000000000000000333333333333330000000000000000000044444444440000000000000000000
00000000000000000000000000000000000000333300000000000000000000003333333333333333000000000000000000044444444440000000000000000000
00000000000000000000000000000000000003333330000000000000000000033333333333333333300000000000000000044444444440000000000000000000
00000000000000000000000000000000000033333333000000000000000003333333333333333333333000000000000000044444444440000000000000000000
00000000000000000000000000000000000033333333000000000000000333333333333333333333333330000000000000044444444440000000000000000000
00000000000000000000000000000000000333333333300000000000000000033333333333333333300000000000000000044444444440000000000000000000
00000000000000000000000000000000000333333333300000000000000000003333333333333333000000000000000000444444444444000000000000000000
00000000000000000000000000000000003333333333330000000000000000033333333333333333300000000000000000444444444444000000000000000000
00000000000000000000000000000000003333333333330000000000000000333333333333333333330000000000000004444444444444400000000000000000
00000000000000000000000000000000033333333333333000000000000003333333333333333333333000000000000044444444444444440000000000000000
00000000000000000000000000000000333333333333333300000000000033333333333333333333333300000000004444444444444444444400000000000000
00000000000000000000000000000003333333333333333330000000003333333333333333333333333333000000444444444444444444444444000000000000
00000000000000000000000000000033333333333333333333000000333333333333333333333333333333334444444444444444444444444444444400000000
000000ffff00000000000000000000000009900000099000bbbbbbbb555565550000300000000000000000000000000000000000000000000000000000000000
00000f0000f0000000000000000000000009900000099000b3bbb3bb555565550003330000000000000000000000000000000000000000000000000000000000
0000f000000f000000000000000000000088880000888800b3bb3bb3555666550033330000000000000000000000000000000000000000000000000000000000
0000f000000f000000000000000000000888888008888880bbbbbbbb655666550333333000000000000000000000000000000000000000000000000000000000
0000f000000f000000000000000000000888888008888880bbbbbb3b666666650033330000000000000000000000000000000000000000000000000000000000
0000f000000f000000000000000000000988889090888890bb3bbb3b666666660333333000000000000000000000000000000000000000000000000000000000
00000f0000f00000000000000000000000cccc0000cccc00bb3bbbbb666666663334433300000000000000000000000000000000000000000000000000000000
000000ffff000000000000000000000000c0c000000c0c00b3b33bb3666666660004400000000000000000000000000000000000000000000000000000000000
0000000ff00000000000000000000000000990000009900000000000000000003334433300000000000000000000000000000000000000000000000000000000
0000000ff00000000000000000000000000990000009900000000000000000003b3443bb00000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000000c77c0000c77c0000000000000000003b3443b300000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000007c77c7007c77c7000000000000000003344443300000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000007c77c7007cccc7000000000000000003444444300000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000009cccc9090cccc90000000000000000033bb333300000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000000cccc0000cccc00000000000000000033b3333b00000000000000000000000000000000000000000000000000000000
0000000ff0000000000000000000000000c0c000000c0c000000000000000000333333b300000000000000000000000000000000000000000000000000000000
0000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000f00ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000f000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ff00000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008ff0000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00800000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00232425260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00333435360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a002728292a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a003738393a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a00002c2d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a000b2c2d0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000000000000000000000001a001b2c2d1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a00000000093b3c3d3e0a000000001a002b2c2d2e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a0a090a0919191919191a09090a0a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a1a1a1a1a1a19191a19191a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474701474747474747474747474700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747474747474747474747474747474700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646464646464646464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646464646464646464646464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646465846464747464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646464647474746464646460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646464646464646464646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464658464646464646465846000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464646464646474746464600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464647464646464746460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4747464647464646464746460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

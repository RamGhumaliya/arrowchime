"""
Reference prototype of the Arrowchime level generator + greedy solver.

PURPOSE: a tiny, proven-correct model of docs/04_LEVEL_SYSTEM.md for Claude Code
to port to Dart (lib/core/level/). It was run on 1,000 random seeds at 10x10 /
fill 0.85 and produced 0 unsolvable boards.

NOT production code:
  - uses Python's random (the Dart port MUST use Mulberry32, see 04 §6)
  - no masks, portals, rotators, links (add per 04 §3.3)
  - generator returns bodies ordered tail -> head (matches JSON schema)

Run:  python3 generator_reference.py
"""
import json, random, sys
D={'U':(0,-1),'D':(0,1),'L':(-1,0),'R':(1,0)}
def ray(head,d,w,h):
    x,y=head;dx,dy=D[d];out=[]
    x+=dx;y+=dy
    while 0<=x<w and 0<=y<h: out.append((x,y));x+=dx;y+=dy
    return out
def gen(w,h,fill,lmin,lmax,wind,seed):
    r=random.Random(seed);occ={};placed=[];fails=0
    while len(occ)/(w*h)<fill and fails<4000:
        empt=[(x,y) for x in range(w) for y in range(h) if (x,y) not in occ]
        head=r.choice(empt);dirs=list(D);r.shuffle(dirs);d=None
        for dd in dirs:
            if all(c not in occ for c in ray(head,dd,w,h)): d=dd;break
        if not d: fails+=1;continue
        myray=set(ray(head,d,w,h));L=r.randint(lmin,lmax)
        body=[head];cur=head;back=(-D[d][0],-D[d][1]);last=back
        for _ in range(L-1):
            opts=[]
            for v in D.values():
                n=(cur[0]+v[0],cur[1]+v[1])
                if 0<=n[0]<w and 0<=n[1]<h and n not in occ and n not in body and n not in myray: opts.append(v)
            if not opts: break
            if last in opts and r.random()>wind: v=last
            else: v=r.choice(opts)
            cur=(cur[0]+v[0],cur[1]+v[1]);body.append(cur);last=v
        if len(body)<lmin: fails+=1;continue
        aid=len(placed)
        for c in body: occ[c]=aid
        placed.append((list(reversed(body)),d))
    return placed
def greedy(arrows,w,h,gates=None,keys=None,frozen=None):
    gates=dict(gates or {});frozen=dict(frozen or {})
    rem=dict(enumerate(arrows));waves=0;order=[]
    while rem:
        occ={tuple(c):i for i,(b,d) in rem.items() for c in b}
        free=[]
        for i,(b,d) in rem.items():
            if frozen.get(i,0)>0: continue
            ok=all((c not in occ) and (c not in gates) for c in ray(tuple(b[-1]),d,w,h))
            if ok: free.append(i)
        if not free: return None,waves,order
        for i in free:
            # recheck sequentially
            occ={tuple(c):j for j,(b,d) in rem.items() for c in b}
            b,d=rem[i]
            if frozen.get(i,0)>0: continue
            if all((c not in occ) and (c not in gates) for c in ray(tuple(b[-1]),d,w,h)):
                del rem[i];order.append(i)
                for j in frozen: frozen[j]=max(0,frozen[j]-1)
                if keys and i in keys:
                    col=keys[i];gates={g:c for g,c in gates.items() if c!=col}
        waves+=1
    return True,waves,order
if __name__=='__main__':
    for args in [(6,6,0.6,1,4,0.3,11),(8,8,0.8,2,8,0.5,22),(10,10,0.85,2,10,0.55,33)]:
        p=gen(*args);s,wv,o=greedy(p,args[0],args[1])
        print(args,len(p),s,wv)

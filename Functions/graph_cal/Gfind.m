function G=Gfind(i,j,mpc)
[m,n]=size(j);
 if m==1
   A=find(mpc.branch(:,1)==i);
   B=find(mpc.branch(:,2)==j);
   C=find(mpc.branch(:,1)==j);
   D=find(mpc.branch(:,2)==i);
   if intersect(A,B)
     G=mpc.branch(intersect(A,B),3);
     B=mpc.branch(intersect(A,B),4);
   elseif intersect(C,D)
     G=mpc.branch(intersect(C,D),3);
     B=mpc.branch(intersect(C,D),4);
   else
     G=[];
     B=[];
   end
 else
   G=zeros(m,n);
   B=zeros(m,n);
     for k=1:m
      A=find(mpc.branch(:,1)==i);
      B=find(mpc.branch(:,2)==j(k,1));
      C=find(mpc.branch(:,1)==j(k,1));
      D=find(mpc.branch(:,2)==i);
        if intersect(A,B)
           G(k,1)=sum(mpc.branch(intersect(A,B),3));
           B(k,1)=sum(mpc.branch(intersect(A,B),4));
        elseif intersect(C,D)
           G(k,1)=sum(mpc.branch(intersect(C,D),3));
           B(k,1)=sum(mpc.branch(intersect(C,D),4));
        else
           G=[];
           B=[];  
        end
     end
 end 
end
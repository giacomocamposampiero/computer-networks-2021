#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/types.h>          /* See NOTES */
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int tmp;

struct header{
    char * n;
    char * v;
}h[100];

int main() {
    char * statusline;
    struct sockaddr_in addr;
    int i,j,k,s,t;
    char request[5000],response[1000000];
    unsigned char targetip[4] = {216,58,209,46};
    //unsigned char targetip[4] = { 213,92,16,101 };
    s =  socket(AF_INET, SOCK_STREAM, 0);
    if ( s == -1 ){
	    tmp=errno;
	    perror("Socket fallita");
	    printf("i=%d errno=%d\n",i,tmp);
	    return 1;
	}
    addr.sin_family = AF_INET;
    addr.sin_port = htons(80);
    addr.sin_addr.s_addr = *(unsigned int*)targetip; // <indirizzo ip del server 216.58.213.100 >

    if ( -1 == connect(s,(struct sockaddr *)&addr, sizeof(struct sockaddr_in)))
	    perror("Connect fallita"); 
    sprintf(request,"GET /pluto HTTP/1.0\r\n\r\n");
    if ( -1 == write(s,request,strlen(request))){perror("write fallita"); return 1;}

    statusline = h[0].n=response;
    // define length of the body
    int body = 0;
    for( j=0,k=0; read(s,response+j,1);j++){
		if(response[j]==':' && (h[k].v==0) ){
			response[j]=0;
			h[k].v=response+j+2;
		}
		else if((response[j]=='\n') && (response[j-1]=='\r') ){
			response[j-1]=0;
			if(h[k].n[0]==0) break;
            if(k!=0 && !strcmp(h[k].n, "Content-Length")){
                body = atoi(h[k].v);
            }
			h[++k].n=response+j+1;
		}
    }	

    printf("Status line = %s\n",statusline);   
    for(i=1;i<k;i++)
	    printf("%s ----> %s\n",h[i].n, h[i].v);


    for(int curr=0; curr < body; curr++) {
        read(s,response+j,1);     
        printf("%c",response[j]);
	    j++;
	}
	if ( t == -1) { perror("Read fallita"); return 1;}
}


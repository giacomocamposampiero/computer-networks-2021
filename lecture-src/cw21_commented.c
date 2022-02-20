#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/types.h>          /* See NOTES */
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>

int tmp;

// structure that contains an HTTP header
// each header is a pair (name:value)
struct header{
    char * n;
    char * v;
} h[100];

int main() {
    char * statusline;
    struct sockaddr_in addr;
    int entity_length;
    int i,j,k,s,t;
    char request[5000],response[10000];
    char * entity; 
    unsigned char targetip[4] = { 216, 58 ,213,100 };
    //unsigned char targetip[4] = { 213,92,16,101 };
    // open the socket for the connection
    s =  socket(AF_INET, SOCK_STREAM, 0);
    if ( s == -1 ){
        // if the socket has not been opened, print the error that occured
        // the error is stored in the 
	    tmp=errno;
	    perror("Socket fallita");
	    printf("i=%d errno=%d\n",i,tmp);
	    return 1;
	}
    // open the connection over the socket that was created before
    addr.sin_family = AF_INET;
    addr.sin_port = htons(80);
    addr.sin_addr.s_addr = *(unsigned int*)targetip; // <indirizzo ip del server 216.58.213.100 >
    if ( -1 == connect(s,(struct sockaddr *)&addr, sizeof(struct sockaddr_in)))
	    perror("Connect fallita"); 
    
    // printf("%d\n",s); // if not commented, prints the id of the associated socket
    
    // for loop to perform multiple requests of the same page
    for(int iter=0;iter<1;iter++){
        // print the request in the proper buffer
	    sprintf(request,"GET /pluto HTTP/1.0\r\nConnection:keep-alive\r\n\r\n");
	    // send the request 
        if ( -1 == write(s,request,strlen(request))){perror("write fallita"); return 1;}
        bzero(h,sizeof(struct header)*100);
        // status line is the first part of the response
	    statusline = h[0].n=response;
        // header parsing
	    for( j=0,k=0; read(s,response+j,1);j++){
			if(response[j]==':' && (h[k].v==0) ){
				response[j]=0;
				h[k].v=response+j+1;
			}
			else if((response[j]=='\n') && (response[j-1]=='\r') ){
				response[j-1]=0;
				if(h[k].n[0]==0) break;
				h[++k].n=response+j+1;
			}
	    }	
	    entity_length = -1;
	    // printf("Status line = %s\n",statusline); // if the comment is removed, print the 
                                                    // status line of the response
	    // get the content length from the corresponding header, if any
        for(i=1;i<k;i++){
		    if(strcmp(h[i].n,"Content-Length")==0){
			    entity_length=atoi(h[i].v);
			    // if the line below is uncommented, print the content-length, if any
                // printf("* (%d) ",entity_length);
		    }
            // if uncommented, print each header
            //printf("%s ----> %s\n",h[i].n, h[i].v);
	    }
        
        // if entity length is known, allocate a buffer that perfectly fit the content
        // otherwise, allocate a buffer of a generic dimension
	    if(entity_length == -1) entity_length=1000000;
	    entity = (char * ) malloc(entity_length);
        // fill the buffer with the entity body
	    for(j=0; (t=read(s,entity+j,entity_length-j))>0;j+=t);
	    
        // print the entity body
	    for(i=0;i<j;i++) printf("%c",entity[i]);
	}
}

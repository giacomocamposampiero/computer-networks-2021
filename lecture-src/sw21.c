#include <stdlib.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/types.h>          /* See NOTES */
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>

int tmp;

struct header{
    char * n;
    char * v;
}h[100];

int main()
{
    struct sockaddr_in addr,remote_addr;
    int i,j,k,s,t,s2,len;
    char command[100];
    int c;
    FILE * fin;
    int yes=1;
    char * commandline;
    char * method, *path, *ver;
    char request[5000],response[10000];
    s =  socket(AF_INET, SOCK_STREAM, 0);
    if ( s == -1 ){ perror("Socket fallita"); return 1; }
    addr.sin_family = AF_INET;
    addr.sin_port = htons(8053);
    addr.sin_addr.s_addr = 0;
    t= setsockopt(s,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(int));
    if (t==-1){perror("setsockopt fallita"); return 1;}
    if ( bind(s,(struct sockaddr *)&addr, sizeof(struct sockaddr_in)) == -1) {perror("bind fallita"); return 1;}
    if ( listen(s,5) == -1 ) { perror("Listen Fallita"); return 1; }
    len = sizeof(struct sockaddr_in);
    while(1){
        s2 =  accept(s, (struct sockaddr *)&remote_addr,&len);
        if ( s2 == -1 ) { perror("Accept Fallita"); return 1;}
        bzero(h,100*sizeof(struct header *));
        commandline = h[0].n=request;
        for( j=0,k=0; read(s2,request+j,1);j++){
            if(request[j]==':' && (h[k].v==0) ){
                request[j]=0;
                h[k].v=request+j+1;
            }
            else if((request[j]=='\n') && (request[j-1]=='\r') ){
                request[j-1]=0;
                if(h[k].n[0]==0) break;
                h[++k].n=request+j+1;
            }
        }	
        printf("Command line = %s\n",commandline);   
        for(i=1;i<k;i++){
            printf("%s ----> %s\n",h[i].n, h[i].v);
        }
        method = commandline;
        for(i=0;commandline[i]!=' ';i++){} commandline[i]=0; path = commandline+i+1;
        for(i++;commandline[i]!=' ';i++); commandline[i]=0; ver = commandline+i+1;
        for(i++;commandline[i]!='\r';i++); commandline[i]=0;
        printf("method=%s path=%s ver=%s\n",method,path,ver);
        if(strncmp(path,"/cgi-bin/",9) == 0){
            sprintf(command,"%s > tmpfile.txt", path+9);
            printf("Eseguo il comando %s\n",command);
            t=system(command);
            if (t != -1)
                strcpy(path+1,"tmpfile.txt");	
        }
        char completepath[50];
        sprintf(completepath, "%s%s", "html/", path+1);
        if ((fin = fopen(completepath,"rt"))==NULL){
            sprintf(response,"HTTP/1.1 404 Not Found\r\n\r\n");
            write(s2,response,strlen(response));
        }
        else {
            sprintf(response,"HTTP/1.1 200 OK\r\n\r\n");
            write(s2,response,strlen(response));
            while ( (c = fgetc(fin)) != EOF ) 
                write(s2,&c,1);
            fclose(fin);	
        }
        close(s2);
    }
}


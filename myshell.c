// Or Itzhaki 209335058
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/wait.h>

#define MAX_COMMAND_LENGTH 100
#define MAX_NUM_ARGUMENTS 10
#define MAX_HISTORY_COMMANDS 100

char command_history[MAX_HISTORY_COMMANDS][MAX_COMMAND_LENGTH];
int pid_history[MAX_HISTORY_COMMANDS];
int history_len = 0;

//prints the prompt for the user to interact with:
void print_prompt(){
    printf("$ "); // the prompt
    fflush(stdout);
}

// breaks the command into tokens (words):
void break_up_command(char* command, char** args){
    int i = 0;
    char *token = strtok(command, " ");
    while (token != NULL && i < MAX_NUM_ARGUMENTS) {
        args[i] = token;
        token = strtok(NULL, " ");
        i++;
    }
    args[i] = NULL; // for exec
}

// add given paths to environment variable
void add_paths(int argc, char* argv[]) {
    for (int i = 0; i < argc; i++) {
        char *path = getenv("PATH");
        strcat(path, ":/");
        strcat(path, argv[i]);
        setenv("PATH", path, 0);
    }
}

//implementation of the history command:
void history_command() {
    for (int i = 0; i < history_len; i++) { // print all history
        printf("%d %s\n", pid_history[i], command_history[i]);
    }
}

//implementation of cd command:
void cd_command(char** args){
    if (args[1] == NULL) { // move to home
        chdir(getenv("HOME"));
    } else {
        if (chdir(args[1]) != 0) { // move to given path
            perror("chdir failed");
        }
    }
}

//adds a command to the history:
void add_to_history(char* command, pid_t pid){
    if(history_len < MAX_HISTORY_COMMANDS){
        strcpy(command_history[history_len], command);
        pid_history[history_len] = pid;
        history_len++;
    }
}

//the main program of the shell:
int main(int argc, char *argv[]) {
    int run = 1; // flag
    add_paths(argc, argv);
    char command[MAX_COMMAND_LENGTH]; // will hold the command inserted by user
    char *args[MAX_NUM_ARGUMENTS]; //will hold each word in the command as strings
    while (run) { // loop continuously for the user to insert commands
        print_prompt();
        if (fgets(command, MAX_COMMAND_LENGTH, stdin) == NULL) { // get the command from the user
            perror("read failed");
            continue;
        }
        command[strlen(command)-1] = '\0'; // remove the newline character
        if (strlen(command) == 0) { // check for empty input
            continue;
        }

        break_up_command(strdup(command), args);

        // check if one of these commands:
        if (strcmp(args[0], "exit") == 0) {
            run = 0;
            continue;
        } else if (strcmp(args[0], "history") == 0) {
            add_to_history(command, getpid());
            history_command();
            continue;
        } else if (strcmp(args[0], "cd") == 0) {
            pid_t ppid = getpid();
            add_to_history(command, ppid);
            cd_command(args);
            continue;
        }

        pid_t pid = fork(); // create a child process for executing command:
        if (pid == 0) { // child process
            execvp(args[0], args); //sending the command for execution with the child process
            printf("Command not found: %s\n", args[0]); // will only print if execvp failed
            exit(EXIT_FAILURE);
        } else if (pid == -1) {
            printf("Failed to fork process\n");
        } else {
            add_to_history(command, pid);
            wait(NULL);
        }
    }
    return 0;
}

%{
    #include<string.h>
    #include<time.h>
    #include<stdlib.h>


    char* scenario;
    int num_players = 0;
    int live_players;
    char* players[4];
    int players_health[4] = {100, 100, 100, 100};
    int player_turn = 0;
    int machine_gun_damage = 20;
    int selected_weapon_damage = 30;
    int special_move_damage = 40;
    
%}

start_game "Start"
start_match "Start Match"
scenarios "Moscow"|"Paris"|"Amazonia"|"New York"|"Antartica"|"Holland"|"Hong Kong"|"Dark Tooth"
characters "Axel"|"Grasshopper"|"Mr. Grimm"|"Hammerhead"|"Minion"|"Outlaw 2"|"Roadkill"|"Shadow"|"Mr. Slam"|"Spectre"|"Sweettoth"|"Thumper"|"Twister"|"Warthog"|"Darktooth"
moves [ULDRTBS]
change_weapon "L1"|"R1"
weapon "L2"|"R2"

%%
{start_game}    {
    printf("\nGame Started\n");
    printf("\nSelecting scenario...");
}

{scenarios} {
    scenario = yytext;
    printf("Scenario selected: %s\n", scenario);
    printf("\nSelecting Characters...");
}

{characters} {
    if(num_players < 4){
        if(strcmp(yytext, "Minion") == 0 || strcmp(yytext, "Sweettooth") == 0){
            printf("Oh! Can't select special character");
            break;
        }
        if(strcmp(yytext, "Darktooth") == 0){
            printf("Can't select special character");
            break;
        }

        for(int i=0; i<num_players; i++){
            if(strcmp(yytext, players[i]) == 0){
                printf("Oh! Character \"%s\" already selected\n", yytext);
                exit(1);
            }
        }
        players[num_players] = malloc(sizeof(char) * (yyleng + 1));
        strcpy(players[num_players], yytext);
        num_players++;
        printf("Player %d select: %s", num_players, players[num_players-1]);
    }else{
        printf("Oh! Max number of players reached: (max 4)");
    }
}

{start_match} {
    if(num_players > 1){
        printf("\nStarting match...\n");
        live_players = num_players;
    }else{
        printf("Oh!, need at leas two players to start");
        exit(1);
    }
}

{characters}":"({moves}|{change_weapon})+":"{weapon} {
    char *player, *moves, *weapon, *str;
    int valid_player = -1;
    int selected_damage;
    str = strdup(yytext);
    player = strsep(&str, ":");
    moves = strsep(&str, ":");
    weapon = strsep(&str, ":");

    for(int i=0; i<num_players; i++){
        if(strcmp(players[i], player) == 0){
            valid_player = i;
            break;
        }
    }

    if(valid_player >= 0){
        printf("%s's turn...\n", player);
        if(players_health[valid_player] <= 0){
            printf("Player \"%s\" already eliminated\n", player);
            break;
        }
    }else{
        printf("Oh! Invalid Player");
        exit(1);
    }

    printf("%s", player);
    for(int i=0; moves[i] != '\0'; i++){
        if(i == 0){
            printf(": ");
        }else{
            printf(", ");
        }
        switch(moves[i]){
            case 'U':
                printf("Moves Up");
                break;
            case 'L':
                if(i+1 < strlen(moves) && moves[i+1] == '1'){
                    printf("Shift selected weapon to the left");
                    i++;
                }else{
                    printf("Moves Left");
                }
                break;
            case 'D':
                printf("Moves Back");
                break;
            case 'R':
                if(i+1 < strlen(moves) && moves[i+1] == '1'){
                    printf("Shift selected weapon to the right");
                    i++;
                }else{
                    printf("Moves Right");
                }
                break;
            case 'T':
                printf("Activates Turbo");
                break;
            case 'B':
                printf("Brakes");
                break;
            case 'S':
                printf("Accelerates");
                break;
        }
    }
    printf("\n");

    int victim_index = -1;

    while(victim_index < 0 || victim_index == valid_player || players_health[victim_index] <= 0){
        victim_index = rand() % num_players;
    }

    if(strcmp(weapon, "L2")){
        printf("%s fire with selected weapon to %s\n", players[valid_player], players[victim_index]);
        selected_damage = selected_weapon_damage;
    }else if(strcmp(weapon, "R2")){
        printf("%s fire with machine gun to %s\n", players[valid_player], players[victim_index]);
        selected_damage = machine_gun_damage;
    }

    int shot_prob = rand() % 2;

    if(shot_prob == 0){
        printf("Shot missed\n");
    }else{
        players_health[victim_index] -= selected_damage;
        int victim_health = players_health[victim_index];
        if(victim_health < 0){
            victim_health = 0;
        }
        printf("successful shot, damage dealt: %d. actual health of %s: %d\n", selected_damage, players[victim_index], victim_health);

        if(players_health[victim_index] <=0 ){
            printf("\n%s Eliminated!! :(\n", players[victim_index]);
            live_players--;
        }
    }

    if(live_players <= 1){
        printf("\nAll players killed\n");
        printf("%s WINS!!!!\n\n", players[valid_player]);
        printf("Game end\n");
        printf("Final Stats:\n");
        for(int i=0; i<num_players; i++){
            int victim_health = players_health[i];
            if(victim_health < 0){
                victim_health = 0;
            }
            printf("\t%s:\t%d\n", players[i], victim_health);
        }
        exit(0);
    }
}


. {
    printf("Token no recognized");
    exit(1);
}
%%

int main(){
    int live_player;
    printf("Twisted Metal Game:\nPress Start...\n");
    srand(time(NULL));
    yylex();

    printf("Game end\n");
    if(live_players == 1){
        for(int i=0; i<num_players; i++){
            if(players_health[i] > 0){
                live_player = i;
                break;
            }
        }
        printf("%s WINS!!!!\n\n", players[live_player]);
    }else{
        printf("DRAW\n");
    }

    printf("Final Stats:\n");
    for(int i=0; i<num_players; i++){
        int victim_health = players_health[i];
        if(victim_health < 0){
            victim_health = 0;
        }
        printf("\t%s:\t%d\n", players[i], victim_health);
    }

}

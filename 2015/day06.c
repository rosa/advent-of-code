/* --- Day 6: Probably a Fire Hazard --- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

#define GRID_SIZE 1000
#define INSTRUCTIONS_COUNT 300

struct Coord
{
    int x;
    int y;
};

enum EAction { OFF, ON, TOGGLE };
struct Instruction
{
    enum EAction action;
    struct Coord from;
    struct Coord to;
};

// turn on 881,159 through 902,312
// turn off 537,651 through 641,816
// toggle 561,947 through 638,965
const char *INSTRUCTION_PATTERN = "^(turn on|turn off|toggle) ([0-9]+),([0-9]+) through ([0-9]+),([0-9]+)";
char *TURN_ON = "turn on";
char *TURN_OFF = "turn off";

enum EAction _get_action(char * instruction)
{
    enum EAction action = TOGGLE;
    if (strcmp(instruction, TURN_ON) == 0) action = ON;
    if (strcmp(instruction, TURN_OFF) == 0) action = OFF;

    return action;
}

void _print(struct Instruction instruction)
{
    printf("Instruction: %u, {%d, %d}, {%d, %d}\n", instruction.action, instruction.from.x, instruction.from.y, instruction.to.x, instruction.to.y);
}


struct Instruction _parse_instruction(char * source)
{
    size_t group_count = 6;
    regmatch_t groups[group_count];
    char *captures[group_count];
    int capture_size = 0;
    regex_t compiled_regex;

    struct Instruction instruction = { .action = OFF, .from = {0, 0}, .to = {0, 0} };

    unsigned int i = 0;

    if (regcomp(&compiled_regex, INSTRUCTION_PATTERN, REG_EXTENDED))
    {
        printf("Could not compile regular expression.\n");
        return instruction;
    }

    if (regexec(&compiled_regex, source, group_count, groups, 0))
    {
        printf("No matches.\n");
        return instruction;
    }

    for (i = 0; i < group_count; i++)
    {
        if (groups[i].rm_so == (size_t)-1)
            break;

        capture_size = groups[i].rm_eo - groups[i].rm_so;
        captures[i] = malloc(capture_size + 1);
        strncpy(captures[i], source + groups[i].rm_so, capture_size);
        captures[i][capture_size] = 0;
    }

    instruction.action = _get_action(captures[1]);
    instruction.from = (struct Coord) { atoi(captures[2]), atoi(captures[3]) };
    instruction.to = (struct Coord) { atoi(captures[4]), atoi(captures[5]) };

    for (i = 0; i < group_count; i++) free(captures[i]);
    regfree(&compiled_regex);

    return instruction;
}

void _read_instructions(char * filename, struct Instruction * instructions)
{
    FILE * fp;
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    unsigned int i = 0;

    fp = fopen(filename, "r");

    while ((read = getline(&line, &len, fp)) != -1 && i < INSTRUCTIONS_COUNT)
    {
        instructions[i] = _parse_instruction(line);
        i++;
    }

    fclose(fp);
    free(line);
}

void _execute_on_off(struct Instruction * instructions, unsigned int (* grid)[GRID_SIZE])
{
    unsigned int i, j, k;

    for (int i = 0; i < GRID_SIZE; ++i)
        for (int j = 0; j < GRID_SIZE; ++j)
            grid[i][j] = 0;

    for (k = 0; k < INSTRUCTIONS_COUNT; k++)
        for (i = instructions[k].from.y; i <= instructions[k].to.y; i++)
            for (j = instructions[k].from.x; j <= instructions[k].to.x; j++)
                if (instructions[k].action == ON) grid[i][j] = 1;
                else if (instructions[k].action == OFF) grid[i][j] = 0;
                else if (instructions[k].action == TOGGLE) grid[i][j] ^= 1;
}

void _execute_increments(struct Instruction * instructions, unsigned int (* grid)[GRID_SIZE])
{
    unsigned int i, j, k;

    for (int i = 0; i < GRID_SIZE; ++i)
        for (int j = 0; j < GRID_SIZE; ++j)
            grid[i][j] = 0;

    for (k = 0; k < INSTRUCTIONS_COUNT; k++)
        for (i = instructions[k].from.y; i <= instructions[k].to.y; i++)
            for (j = instructions[k].from.x; j <= instructions[k].to.x; j++)
                if (instructions[k].action == ON) grid[i][j] += 1;
                else if (instructions[k].action == OFF && grid[i][j] > 0) grid[i][j] -= 1;
                else if (instructions[k].action == TOGGLE) grid[i][j] += 2;
}

int main ()
{
    char * filename = "inputs/input06.txt";
    struct Instruction instructions[INSTRUCTIONS_COUNT];
    unsigned int grid[GRID_SIZE][GRID_SIZE];
    unsigned int count_on = 0;
    unsigned int brightness = 0;
    unsigned int i, j;

    for (i = 0; i < GRID_SIZE; ++i)
        for (j = 0; j < GRID_SIZE; ++j)
            grid[i][j] = 0;

    _read_instructions(filename, instructions);
    _execute_on_off(instructions, grid);

    for (i = 0; i < GRID_SIZE; ++i)
        for (j = 0; j < GRID_SIZE; ++j)
            count_on += grid[i][j];

    printf("Lights on: %u\n", count_on);

    // --- Part Two ---
    _execute_increments(instructions, grid);
    for (i = 0; i < GRID_SIZE; ++i)
        for (j = 0; j < GRID_SIZE; ++j)
            brightness += grid[i][j];

    printf("Total brightness: %u\n", brightness);

}
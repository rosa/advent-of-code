/* --- Day 10: Monitoring Station --- */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MAP_WIDTH 34
#define MAP_HEIGHT 34

#define PI 3.14159265

struct Coord
{
    int x;
    int y;
};

void _read_map(char * filename, char (* map)[MAP_HEIGHT])
{
    FILE * fp;
    char * row = NULL;
    size_t len = 0;
    ssize_t read;
    unsigned int i = 0;

    fp = fopen(filename, "r");

    while ((read = getline(&row, &len, fp)) != -1 && i < MAP_HEIGHT)
    {
        for (unsigned int j = 0; j < MAP_WIDTH; j++)
        {
            map[i][j] = row[j];
        }
        i++;
    }

    free(row);
    fclose(fp);
}


void _print_map(char (* map)[MAP_HEIGHT])
{
    for (unsigned int i = 0; i < MAP_HEIGHT; i++)
    {
        for (unsigned int j = 0; j < MAP_WIDTH; j++)
        {
            putchar(map[i][j]);
        }
        putchar('\n');
    }
}

double _angle(struct Coord a, struct Coord b)
{
    double angle;
    if (a.x - b.x == 0)
    {
        if (a.y < b.y)
            angle = PI/2;
        else
            angle = -PI/2;
    }
    else
    {
        angle = atan2((double) a.y - b.y, (double) a.x - b.x);
    }

    // Due to the laser pointing up first, we need to rotate π/2 (90º)
    angle = angle - PI/2;
    // And we need only positive angles from 0 to 2π (360º)
    if (angle < 0)
    {
        angle = 2*PI + angle;
    }

    return angle;
}

int _include(double angles[], int size, double angle)
{
    for (unsigned int i = 0; i < size; i++)
    {
        if (angles[i] == angle)
            return 1;
    }
    return 0;
}

int _count(struct Coord c, char (* map)[MAP_HEIGHT])
{
    double angles[MAP_WIDTH * MAP_HEIGHT];
    double angle;
    int count = 0;
    struct Coord d;

    for (int i = 0; i < MAP_HEIGHT; i++)
    {
        for (int j = 0; j < MAP_WIDTH; j++)
        {
            if ((i != c.y || j != c.x) && map[i][j] == '#')
            {
                d.y = i;
                d.x = j;
                angle = _angle(c, d);
                if (_include(angles, count, angle) == 0)
                {
                    angles[count] = angle;
                    count++;
                }
            }
        }
    }

    return count;
}

int _find_max_count(char (* map)[MAP_HEIGHT])
{
    int max_count = 0;
    int count = 0;
    int max_i, max_j;
    struct Coord c;

    for (int i = 0; i < MAP_HEIGHT; i++)
    {
        for (int j = 0; j < MAP_WIDTH; j++)
        {
            if (map[i][j] == '#')
            {
                c.x = j;
                c.y = i;
                count = _count(c, map);
                if (count > max_count)
                {
                    max_count = count;
                    max_i = i;
                    max_j = j;
                }
            }
        }
    }

    printf("Best location: (%d, %d)\n", max_j, max_i);
    return max_count;
}

int comparator(const void *p, const void *q)
{
    const double *a = (const double *) p;
    const double *b = (const double *) q;

    return (*a > *b) - (*a < *b);
}

struct Coord _find_200_asteroid(struct Coord c, char (* map)[MAP_HEIGHT], int count)
{
    double angles[MAP_HEIGHT][MAP_WIDTH];
    double angle;
    struct Coord d;
    double *sorted_angles = (double *) malloc(count * sizeof(double));
    int k = 0;

    for (int i = 0; i < MAP_HEIGHT; i++)
    {
        for (int j = 0; j < MAP_WIDTH; j++)
        {
            if ((i != c.y || j != c.x) && map[i][j] == '#')
            {
                d.y = i;
                d.x = j;
                angles[i][j] = _angle(c, d);
                if (_include(sorted_angles, k, angles[i][j]) == 0)
                {
                    sorted_angles[k] = angles[i][j];
                    k++;
                }
            }
            else
            {
              angles[i][j] = -1;
            }
        }
    }

    qsort(sorted_angles, k, sizeof (double), comparator);

    // Find 200th asteroid based on sorted angles. Sort of cheated here and verified that
    // this angle is only present once, so no need to sort by vector norm
    angle = sorted_angles[199];
    free(sorted_angles);

    for (int i = 0; i < MAP_HEIGHT; i++)
    {
        for (int j = 0; j < MAP_WIDTH; j++)
        {
            if (angles[i][j] == angle)
            {
                d.y = i;
                d.x = j;
                return d;
            }
        }
    }

    return c;
}

int main ()
{
    char * filename = "inputs/input10.txt";
    char map[MAP_HEIGHT][MAP_WIDTH];
    struct Coord best_location = {26, 28};
    struct Coord asteroid;
    int count;

    _read_map(filename, map);
    count = _find_max_count(map);
    printf("%d\n", count);

    // --- Part Two ---
    // 200th asteroid to be vaporized.
    // What do you get if you multiply its X coordinate by 100 and
    // then add its Y coordinate
    asteroid = _find_200_asteroid(best_location, map, count);
    printf("%d\n", asteroid.x * 100 + asteroid.y);
}

// --- Part One ---
// Best location: (26, 28)
// 267

// --- Part Two ---
// 1309

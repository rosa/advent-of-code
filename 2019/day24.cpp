// --- Day 24: Planet of Discord ---

#include <array>
#include <fstream>
#include <iostream>
#include <map>
#include <string>

void parseGrid(std::fstream& in, std::array<bool, 25>& grid)
{
    std::string line;
    int i = 0;

    grid.fill(false);

    while (std::getline(in, line))
    {
        for (int j = 0; j < line.size(); j++)
        {
            if (line[j] == '#')
                grid[5*i + j] = true;
        }
        i++;
    }
}

void printGrid(std::array<bool, 25>& grid)
{
    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 5; j++)
            if (grid[5*i + j])
                std::cout << "#";
            else
                std::cout << ".";

        std::cout << "\n";
    }
    std::cout << "\n";
}

void printLevels(std::map<int, std::array<bool, 25>>& levels)
{
    for (std::pair<int, std::array<bool, 25>> level : levels)
    {
        std::cout << "Level: " << level.first << '\n';
        printGrid(level.second);
    }
}


unsigned long biodiversityRating(std::array<bool, 25>& grid)
{
    std::bitset<25> bits;
    for (int i = 0; i < 25; i++)
        if (grid[i])
            bits.set(i);
    return bits.to_ulong();
}

int countBugs(std::array<bool, 25>& grid)
{
    int count = 0;
    for (int i = 0; i < 25; i++)
        if (grid[i])
            count++;
    return count;
}

int countBugs(std::map<int, std::array<bool, 25>>& levels)
{
    int count = 0;

    for (std::pair<int, std::array<bool, 25>> level : levels)
        count += countBugs(level.second);

    return count;
}


void setAdjacents(std::array<bool, 25>& grid, int i, int j, std::bitset<4>& adjacents)
{
  // Check up, right, down, left
    if (i-1 >= 0 && grid[(i-1)*5 + j])
        adjacents.set(0);
    if (j+1 < 5 && grid[i*5 + j+1])
        adjacents.set(1);
    if (i+1 < 5 && grid[(i+1)*5 + j])
        adjacents.set(2);
    if (j-1 >= 0 && grid[i*5 + j-1])
        adjacents.set(3);
}

void setAdjacents(std::map<int, std::array<bool, 25>>& levels, int i, int j, int l, std::bitset<8>& adjacents)
{
    std::array<bool, 25> grid;
    std::array<bool, 25> levelContainingGrid;
    std::array<bool, 25> levelWithinGrid;
    int a = 0;

    // Central tile: ignore. This is the entry to within level
    if (i == 2 && j == 2)
        return;

    // Not started within or outer levels. Ignore
    if ((levels.count(l-1) == 0 || levels.count(l+1) == 0))
    {
        return;
    }
    // if ( && countBugs(levelWithinGrid) == 0 && countBugs(grid) == 0)
    // {
    //     std::cout << "Ignoring " << l << '\n';
    //     return;
    // }

    grid = levels[l];
    levelContainingGrid = levels[l-1];
    levelWithinGrid = levels[l+1];

    //      |     |         |     |     
    //   0  |  1  |    2    |  3  |  4  
    //      |     |         |     |     
    // -----+-----+---------+-----+-----
    //      |     |         |     |     
    //   5  |  6  |    7    |  8  |  9 
    //      |     |         |     |     
    // -----+-----+---------+-----+-----
    //      |     |A|B|C|D|E|     |     
    //      |     |-+-+-+-+-|     |     
    //      |     |F|G|H|I|J|     |     
    //      |     |-+-+-+-+-|     |     
    //  10  | 11  |K|L|?|N|O|  13 |  14 
    //      |     |-+-+-+-+-|     |     
    //      |     |P|Q|R|S|T|     |     
    //      |     |-+-+-+-+-|     |     
    //      |     |U|V|W|X|Y|     |     
    // -----+-----+---------+-----+-----
    //      |     |         |     |     
    //  15  | 16  |    17   |  18 |  19
    //      |     |         |     |     
    // -----+-----+---------+-----+-----
    //      |     |         |     |     
    //  20  | 21  |    22   |  23 |  24
    //      |     |         |     |     

    // Check up, right, down, left

    // Top row , go to the level that contains this one, to tile 7
    if (i == 0 && levelContainingGrid[7])
    {
        adjacents.set(a);
        a++;
    }
    // Tile 17: look at 5 bottom tiles in within level
    if (5*i + j == 17)
    {
        for (int k = 20; k < 25; k++)
            if (levelWithinGrid[k])
            {
                adjacents.set(a);
                a++;
            }
    }
    // No top row or tile 17, look up within this level
    if (i-1 >= 0 && grid[(i-1)*5 + j])
    {
        adjacents.set(a);
        a++;
    }

    // Right-most row, go to the level that contains this one, to tile 13
    if (j+1 == 5 && levelContainingGrid[13])
    {
        adjacents.set(a);
        a++;
    }
    // Tile 11: look at left-most tiles in within level
    if (5*i + j == 11)
    {
        for (int k = 0; k < 5 ; k++)
            if (levelWithinGrid[5*k])
            {
                adjacents.set(a);
                a++;
            }
    }
    // No right-most row or tile 11, look right within this level
    if (j+1 < 5 && grid[i*5 + j+1])
    {
        adjacents.set(a);
        a++;
    }

    // Bottom row: go to the level that contains this one, to tile 17
    if (i+1 == 5 && levelContainingGrid[17])
    {
        adjacents.set(a);
        a++;
    }
    // Tile 7: look at 5 top tiles in within level
    if (5*i + j == 7)
    {
        for (int k = 0; k < 5; k++)
            if (levelWithinGrid[k])
            {
                adjacents.set(a);
                a++;
            }
    }
    // No bottom row or tile 7, look down within this level
    if (i+1 < 5 && grid[(i+1)*5 + j])
    {
        adjacents.set(a);
        a++;
    }

    // Left-most row: go to the level that contains this one, to tile 11
    if (j == 0 && levelContainingGrid[11])
    {
        adjacents.set(a);
        a++;
    }
    // Tile 13: look at right-most tiles in within level
    if (5*i + j == 13)
    {
        for (int k = 0; k < 5 ; k++)
            if (levelWithinGrid[5*k + 4])
            {
                adjacents.set(a);
                a++;
            }
    }
    // No left-most row or tile 13, look left within this level
    if (j-1 >= 0 && grid[i*5 + j-1])
    {
        adjacents.set(a);
        a++;
    }
}


bool bugDies(std::array<bool, 25>& grid, int i, int j)
{
    std::bitset<4> adjacents;
    setAdjacents(grid, i, j, adjacents);
    return adjacents.count() != 1;
}

bool bugDies(std::map<int, std::array<bool, 25>>& levels, int i, int j, int l)
{
    std::bitset<8> adjacents;
    setAdjacents(levels, i, j, l, adjacents);
    return adjacents.count() != 1;
}

bool becomesInfected(std::array<bool, 25>& grid, int i, int j)
{
    std::bitset<4> adjacents;
    setAdjacents(grid, i, j, adjacents);
    return adjacents.count() == 1 || adjacents.count() == 2;
}

bool becomesInfected(std::map<int, std::array<bool, 25>>& levels, int i, int j, int l)
{
    std::bitset<8> adjacents;
    setAdjacents(levels, i, j, l, adjacents);
    return adjacents.count() == 1 || adjacents.count() == 2;
}


void copy(std::array<bool, 25>& grid, std::array<bool, 25>& gridCopy)
{
    gridCopy.fill(false);
    for (int i = 0; i < 25; i++)
        if (grid[i])
            gridCopy[i] = true;
}

void copy(std::map<int, std::array<bool, 25>>& levels, std::map<int, std::array<bool, 25>>& levelsCopy)
{
    for (std::pair<int, std::array<bool, 25>> level : levels)
        copy(level.second, levelsCopy[level.first]);
}


void initLevels(std::map<int, std::array<bool, 25>>& levels, int steps)
{
    // At most 2 new levels are added in each step, so we go from -steps to +steps
    for (int i = -steps; i <= steps; i++)
        levels[i];
}

void step(std::array<bool, 25>& grid, std::array<bool, 25>& newGrid)
{
    newGrid.fill(false);
    for (int i = 0; i < 5; i++)
        for (int j = 0; j < 5; j++)
            if ((grid[i*5 + j] && !bugDies(grid, i, j)) || (!grid[i*5 + j] && becomesInfected(grid, i, j)))
                newGrid[i*5 + j] = true;
}

void step(std::map<int, std::array<bool, 25>>& levels, std::map<int, std::array<bool, 25>>& newLevels)
{
    std::array<bool, 25> grid;
    int l;

    for (std::pair<int, std::array<bool, 25>> level : levels)
    {
        l = level.first;
        grid = level.second;
        newLevels[l].fill(false);

        for (int i = 0; i < 5; i++)
            for (int j = 0; j < 5; j++)
                if ((grid[i*5 + j] && !bugDies(levels, i, j, l)) || (!grid[i*5 + j] && becomesInfected(levels, i, j, l)))
                    newLevels[l][i*5 + j] = true;
    }
}

unsigned long simulate(std::array<bool, 25>& grid)
{
    std::map<unsigned long, bool> seenLayouts;
    unsigned long rating = biodiversityRating(grid);
    std::array<bool, 25> newGrid;

    do
    {
        seenLayouts[rating] = true;
        step(grid, newGrid);
        copy(newGrid, grid);
        rating = biodiversityRating(grid);
    } while (seenLayouts.find(rating) == seenLayouts.end());

    return rating;
}

int simulate(std::map<int, std::array<bool, 25>>& levels, int steps)
{
    std::map<int, std::array<bool, 25>> newLevels;
    initLevels(levels, steps);

    for (int i = 0; i < steps; i++)
    {
        step(levels, newLevels);
        copy(newLevels, levels);
    }

    return countBugs(levels);
}


int main()
{
    std::array<bool, 25> originalGrid;
    std::array<bool, 25> grid;
    unsigned long rating;
    std::map<int, std::array<bool, 25>> levels;
    int count;

    std::fstream in("inputs/input24.txt", std::fstream::in);
    parseGrid(in, originalGrid);
    in.close();

    // --- Part One ---
    copy(originalGrid, grid);
    rating = simulate(grid);
    std::cout << "Rating: " << rating << '\n';

    // --- Part Two ---
    copy(originalGrid, grid);
    levels[0] = grid; // Level 0
    count = simulate(levels, 200);
    std::cout << "Count: " << count << '\n';
}

// Compile with -std=c++11 (C++11 extensions)
// Rating: 3186366
// Count: 2031

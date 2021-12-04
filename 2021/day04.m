// --- Day 4: Giant Squid ---

#import <Foundation/Foundation.h>

@interface Board : NSObject {
    int board [5][5];
    BOOL marked [5][5];
}

@property NSString* identifier;
@property BOOL isActive;

- (instancetype)initWithUnparsedData:(NSArray *)data;
- (void)checkNumber:(NSNumber *) number;
- (BOOL)isBingo;
- (int)score;

@end

@interface Bingo : NSObject {
    NSMutableArray *boards;
    NSArray *numbers;
}

- (instancetype)initWithUnparsedData:(NSString *)data;
- (int)playUntilBingo;
- (int)playUntilTheEnd;
@end


@implementation Board

@synthesize identifier;

- (instancetype)initWithUnparsedData:(NSArray *) data {
    if (self = [super init]) {
        for (int i = 0; i < [data count]; i++) {
            NSArray* numbers = [data[i] componentsSeparatedByString: @" "];
            int k = 0;
            for (int j = 0; j < [numbers count]; j++) {
                NSString *trimmed = [numbers[j] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([trimmed length] > 0 ) {
                    board[i][k] = [trimmed integerValue];
                    marked[i][k] = NO;
                    k++;
                }
            }
        }
    } return self;
}

- (void)checkNumber:(NSNumber *) number {
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            if (board[i][j] == [number integerValue]) {
                marked[i][j] = YES;
                return;
            }
        }
    }
}

- (BOOL)isBingo {
    BOOL bingo = NO;

    // Check rows
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            bingo = marked[i][j];
            if (!bingo) break;
        }
        if (bingo) return YES;
    }

    // Check columns
    for (int j = 0; j < 5; j++) {
        for (int i = 0; i < 5; i++) {
            bingo = marked[i][j];
            if (!bingo) break;
        }
        if (bingo) return YES;
    }

    return bingo;
}

- (int)score {
    int score = 0;

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            if (!marked[i][j]) score += board[i][j];
        }
    }
    return score;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@:\n", identifier];

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            NSString *format = (marked[i][j]) ? @" *%d* " : @"  %d  ";
            NSString *cell = [NSString stringWithFormat:format, board[i][j]];
            [description appendString:cell];
        }
        [description appendString:@"\n"];
    }

    return description;
}

@end


@implementation Bingo

- (instancetype)initWithUnparsedData:(NSString *) data {
    if (self = [super init]) {
        NSArray* lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

        numbers = [[lines.firstObject componentsSeparatedByString: @","] valueForKey:@"integerValue"];

        boards = [[NSMutableArray alloc] init];
        for (int i = 2; i < [lines count]; i+=6) {
            NSRange boardRange = NSMakeRange (i, 5);
            NSArray* boardData = [lines subarrayWithRange:boardRange];
            Board* board = [[Board alloc] initWithUnparsedData:boardData];
            board.identifier = [NSString stringWithFormat:@"Board #%lu", [boards count] + 1];
            board.isActive = YES;

            [boards addObject:board];
        }
    } return self;
}

- (Board *) drawNumber:(NSNumber *) number {
    Board *bingoedBoard = Nil;

    for (Board* board in boards) {
        if (board.isActive) {
            [board checkNumber:number];
            if ([board isBingo]) {
                board.isActive = NO;
                if (!bingoedBoard) bingoedBoard = board;
            }
        }
    }
    return bingoedBoard;
}

- (int) playUntilBingo {
    for (NSNumber *number in numbers) {
        Board *board = [self drawNumber:number];
        if (board) {
            return [board score] * [number integerValue];
        }
    }
    return -1;
}

- (int) playUntilTheEnd {
    Board *lastWinner = Nil;
    NSNumber *lastNumber = numbers.firstObject;

    for (NSNumber *number in numbers) {
        Board *board = [self drawNumber:number];
        if (board) {
            lastWinner = board;
            lastNumber = number;
        }
    }
    return [lastWinner score] * [lastNumber integerValue];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSError *error = nil;
        NSString *data = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

        Bingo *bingo = [[Bingo alloc] initWithUnparsedData:data];
        printf("First winner: %d\n", [bingo playUntilBingo]);

        bingo = [[Bingo alloc] initWithUnparsedData:data];
        printf("Last winner: %d\n", [bingo playUntilTheEnd]);
    }

    return 0;
}

// Using https://github.com/iljaiwas/objc-run to avoid having to setup a whole Xcode project for this
// objc-run day04.m inputs/input04.txt
// First winner: 33462
// Last winner: 30070

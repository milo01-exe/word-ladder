# Word Ladder

A terminal-based word ladder game written in Zig.

## How it works

The game picks a random 4-letter starting word and prompts you to build a ladder — each new word must differ from the previous by exactly one letter and must exist in the word list.

```
Let's make a word ladder! Say `end` to exit.
The ladder is 1 words long. The last word was CATS.
> BATS
The ladder is 2 words long. The last word was BATS.
> BUTS
The ladder is 3 words long. The last word was BUTS.
> end
Exiting…
```

## Running

```sh
zig run word_ladder.zig
```

## Notes

- The word list (`words.txt`) is parsed at compile time and embedded into the binary.
- Words must be exactly 4 letters and present in the word list.
- Type `end` to exit.

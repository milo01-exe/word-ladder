# Word Ladder

A word ladder game written in Zig — playable in the terminal or in a browser.

## How it works

The game picks a random 4-letter starting word. Each word you add must differ from the previous one by exactly one letter and must exist in the word list. See how long a ladder you can build!

## Playing in the terminal

Run the game directly:

```sh
zig run word_ladder.zig
```

The game prompts you for a new word each turn. Type `end` to quit.

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

## Playing in the browser

Start the HTTP server:

```sh
zig run http_server.zig
```

Then open [http://localhost:8000](http://localhost:8000) in your browser. A random starting word is shown automatically. Type your next word in the input box and press Enter to add it to the ladder.

## Notes

- The word list (`words.txt`) is parsed at compile time and embedded into the binary.
- Words must be exactly 4 letters and present in the word list.
- Type `end` to exit (terminal mode only).

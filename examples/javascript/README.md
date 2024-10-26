# javascript

```
$ npm install .
$ npm run build
```

```
$ node dist/cli.js --help
person

  Create a person

Usage:

  person [OPTIONS]

Options:

  (--name NAME) Your name
  (--age AGE)   Your age
  [--help,-h]   Print this help
```

```
$ node dist/cli.js  --name Drew --age 42
Person("Drew", 42)
```

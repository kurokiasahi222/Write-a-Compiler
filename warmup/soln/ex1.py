# ex1.py

def tokenize(text):
    tokens = [ ]    
    n = 0
    while n < len(text):
        if text[n].isspace():
            n += 1
        elif text[n].isdigit():
            start = n
            while n < len(text) and text[n].isdigit():
                n += 1
            tokens.append(('NUM', text[start:n]))
        elif text[n].isalpha():
            start = n
            while n < len(text) and text[n].isalpha():
                n += 1
            tokens.append(('NAME', text[start:n]))
        elif text[n] == '=':
            tokens.append(('ASSIGN', '='))
            n += 1
        elif text[n] in {'+','-','*','/'}:
            tokens.append(('OP', text[n]))
            n += 1
        else:
            print(f"Bad character: {text[n]!r}")
            n += 1
    return tokens

assert list(tokenize("spam = x + 34 * 567")) == \
    [ ('NAME', 'spam'), ('ASSIGN', '='), ('NAME', 'x'), 
      ('OP', '+'), ('NUM', '34'),('OP', '*'), ('NUM', '567')]

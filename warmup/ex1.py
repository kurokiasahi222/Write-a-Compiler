# ex1.py

def tokenize(text):
    pass

assert list(tokenize("spam = x + 34 * 567")) == \
    [ ('NAME', 'spam'), ('ASSIGN', '='), ('NAME', 'x'), 
      ('OP', '+'), ('NUM', '34'),('OP', '*'), ('NUM', '567')]

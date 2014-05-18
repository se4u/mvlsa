def count_and_print(f, l):
    c=0
    for e in l:
        f.write(e)
        f.write("\n")
        c+=1
    f.close()
    return c

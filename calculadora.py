def calcular(expr: str) -> int | float:
    def es_digito(c):
        return c.isdigit()

    estado = "OPA"
    opa, opb, op = 0, 0, None
    i = 0

    while i < len(expr):
        c = expr[i]

        if c.isspace(): 
            i += 1
            continue

        # cuando llega '=', ejecuta
        if c == "=":
            break

        if es_digito(c):
            if estado == "OPA":
                opa = opa * 10 + int(c)
            else:
                opb = opb * 10 + int(c)
            i += 1
            continue

        # detecta operadores
        if c in "+-*/":
            if c == "*" and i + 1 < len(expr) and expr[i + 1] == "*":
                op = "**"
                i += 2
            else:
                op = c
                i += 1
            estado = "OPB"
            continue

        i += 1

    # realiza el cálculo
    if op is None:
        return opa
    if op == "+": res = opa + opb
    elif op == "-": res = opa - opb
    elif op == "*": res = opa * opb
    elif op == "/": res = opa / opb if opb != 0 else float("inf")
    elif op == "**": res = opa ** opb
    else: res = "Operador inválido"

    return res


# Programa principal
if __name__ == "__main__":
    print("Calculadora ensamblador")
    while True:
        entrada = input("> ")
        if entrada.lower() == "exit":
            print("Exit")
            break
        if "=" not in entrada:
            print("Debe terminar con '=' para ejecutar la operación.")
            continue
        try:
            resultado = calcular(entrada)
            print("Resultado:", resultado)
        except Exception as e:
            print("Error:", e)


import sqlite3
import tkinter as tk
from tkinter import messagebox

# Função para conectar ao banco de dados
def connect_db():
    conn = sqlite3.connect('biblioteca.db')
    cursor = conn.cursor()
    return conn, cursor

# Função para criar as tabelas se não existirem
def create_tables():
    conn, cursor = connect_db()
    cursor.execute('''CREATE TABLE IF NOT EXISTS Autores (
        AutorID INTEGER PRIMARY KEY AUTOINCREMENT,
        Nome TEXT NOT NULL,
        Nacionalidade TEXT NOT NULL
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Livros (
        LivroID INTEGER PRIMARY KEY AUTOINCREMENT,
        Titulo TEXT NOT NULL,
        AutorID INTEGER NOT NULL,
        AnoPublicacao INTEGER NOT NULL,
        Genero TEXT NOT NULL,
        FOREIGN KEY (AutorID) REFERENCES Autores(AutorID)
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Emprestimos (
        EmprestimoID INTEGER PRIMARY KEY AUTOINCREMENT,
        LivroID INTEGER NOT NULL,
        DataEmprestimo DATE NOT NULL,
        DataDevolucao DATE NOT NULL,
        NomeUsuario TEXT NOT NULL,
        FOREIGN KEY (LivroID) REFERENCES Livros(LivroID)
    )''')

    cursor.execute('''CREATE TABLE IF NOT EXISTS Usuarios (
        UsuarioID INTEGER PRIMARY KEY AUTOINCREMENT,
        Nome TEXT NOT NULL,
        Email TEXT NOT NULL UNIQUE
    )''')

    conn.commit()
    conn.close()

# Função para adicionar autor
def add_autor():
    nome = entry_nome_autor.get().strip()
    nacionalidade = entry_nacionalidade_autor.get().strip()
    
    if nome and nacionalidade:
        conn, cursor = connect_db()
        cursor.execute("INSERT INTO Autores (Nome, Nacionalidade) VALUES (?, ?)", (nome, nacionalidade))
        conn.commit()
        conn.close()
        messagebox.showinfo("Sucesso", "Autor adicionado com sucesso!")
        entry_nome_autor.delete(0, tk.END)
        entry_nacionalidade_autor.delete(0, tk.END)
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, preencha todos os campos.")

# Função para adicionar livro
def add_livro():
    titulo = entry_titulo_livro.get().strip()
    autor_id = entry_autor_id.get().strip()
    ano_publicacao = entry_ano_livro.get().strip()
    genero = entry_genero_livro.get().strip()

    if titulo and autor_id and ano_publicacao.isdigit() and genero:
        conn, cursor = connect_db()
        cursor.execute("INSERT INTO Livros (Titulo, AutorID, AnoPublicacao, Genero) VALUES (?, ?, ?, ?)", 
                       (titulo, autor_id, int(ano_publicacao), genero))
        conn.commit()
        conn.close()
        messagebox.showinfo("Sucesso", "Livro adicionado com sucesso!")
        entry_titulo_livro.delete(0, tk.END)
        entry_autor_id.delete(0, tk.END)
        entry_ano_livro.delete(0, tk.END)
        entry_genero_livro.delete(0, tk.END)
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, preencha todos os campos corretamente.")

# Função para adicionar empréstimo
def add_emprestimo():
    livro_id = entry_livro_id.get().strip()
    data_emp = entry_data_emp.get().strip()
    data_dev = entry_data_dev.get().strip()
    nome_usuario = entry_nome_usuario.get().strip()

    if livro_id and data_emp and data_dev and nome_usuario:
        conn, cursor = connect_db()
        cursor.execute("INSERT INTO Emprestimos (LivroID, DataEmprestimo, DataDevolucao, NomeUsuario) VALUES (?, ?, ?, ?)", 
                       (livro_id, data_emp, data_dev, nome_usuario))
        conn.commit()
        conn.close()
        messagebox.showinfo("Sucesso", "Empréstimo adicionado com sucesso!")
        entry_livro_id.delete(0, tk.END)
        entry_data_emp.delete(0, tk.END)
        entry_data_dev.delete(0, tk.END)
        entry_nome_usuario.delete(0, tk.END)
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, preencha todos os campos.")

# Função para adicionar usuário
def add_usuario():
    nome = entry_nome_usuario_adicionar.get().strip()
    email = entry_email_usuario.get().strip()

    if nome and email:
        conn, cursor = connect_db()
        try:
            cursor.execute("INSERT INTO Usuarios (Nome, Email) VALUES (?, ?)", (nome, email))
            conn.commit()
            messagebox.showinfo("Sucesso", "Usuário adicionado com sucesso!")
            entry_nome_usuario_adicionar.delete(0, tk.END)
            entry_email_usuario.delete(0, tk.END)
        except sqlite3.IntegrityError:
            messagebox.showwarning("Erro", "Este e-mail já está em uso.")
        finally:
            conn.close()
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, preencha todos os campos.")

# Função para visualizar todos os usuários
def view_usuarios():
    conn, cursor = connect_db()
    cursor.execute("SELECT * FROM Usuarios")
    usuarios = cursor.fetchall()
    conn.close()

    usuarios_list.delete(0, tk.END)
    for usuario in usuarios:
        usuarios_list.insert(tk.END, f"{usuario[1]} (Email: {usuario[2]})")  # Nome e Email

# Função para buscar um usuário específico
def view_usuario_especifico():
    palavra = entry_usuario_especifico.get().strip()
    conn, cursor = connect_db()
    cursor.execute("SELECT * FROM Usuarios WHERE Nome LIKE ? OR Email LIKE ?", ('%' + palavra + '%', '%' + palavra + '%'))
    usuarios = cursor.fetchall()
    conn.close()

    usuarios_list.delete(0, tk.END)
    for usuario in usuarios:
        usuarios_list.insert(tk.END, f"{usuario[1]} (Email: {usuario[2]})")  # Nome e Email

# Função para visualizar empréstimos de um usuário
def view_emprestimos_usuario():
    nome_usuario = entry_usuario_emprestimos.get().strip()
    conn, cursor = connect_db()
    cursor.execute("SELECT * FROM Emprestimos WHERE NomeUsuario = ?", (nome_usuario,))
    emprestimos = cursor.fetchall()
    conn.close()

    emprestimos_list.delete(0, tk.END)
    for emprestimo in emprestimos:
        emprestimos_list.insert(tk.END, f"LivroID: {emprestimo[1]}, Data Emprestimo: {emprestimo[2]}, Data Devolução: {emprestimo[3]}")  # Dados do empréstimo

# Função para buscar livros por gênero
def view_livros_genero():
    genero = entry_genero_busca.get().strip()
    if genero:
        conn, cursor = connect_db()
        cursor.execute("SELECT * FROM Livros WHERE Genero = ?", (genero,))
        livros = cursor.fetchall()
        conn.close()

        livros_list.delete(0, tk.END)
        if livros:
            for livro in livros:
                livros_list.insert(tk.END, f"{livro[1]} (ID: {livro[0]})")  # Título e ID do livro
        else:
            livros_list.insert(tk.END, "Nenhum livro encontrado.")
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, insira um gênero.")

# Função para buscar livros por título ou palavra
def search_livro():
    palavra = entry_busca_livro.get().strip()
    if palavra:
        conn, cursor = connect_db()
        cursor.execute("SELECT * FROM Livros WHERE Titulo LIKE ?", ('%' + palavra + '%',))
        livros = cursor.fetchall()
        conn.close()

        search_result_list.delete(0, tk.END)
        if livros:
            for livro in livros:
                search_result_list.insert(tk.END, f"{livro[1]} (ID: {livro[0]})")  # Título e ID do livro
        else:
            search_result_list.insert(tk.END, "Nenhum livro encontrado.")
    else:
        messagebox.showwarning("Entrada Inválida", "Por favor, insira um título ou palavra.")

# Criação das tabelas ao iniciar
create_tables()

# Configuração da interface gráfica
root = tk.Tk()
root.title('Sistema de Biblioteca')
root.geometry('900x700')  # Ajuste a altura para acomodar mais frames
root.configure(bg='lightblue')

# Estilo de fonte
font_label = ('Arial', 12)
font_entry = ('Arial', 12)

# Frame para adicionar autor
frame_autor = tk.LabelFrame(root, text='Adicionar Autor', bg='lightblue', font=('Arial', 14))
frame_autor.grid(row=0, column=0, padx=10, pady=10, sticky='nsew')

tk.Label(frame_autor, text='Nome:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_nome_autor = tk.Entry(frame_autor, font=font_entry)
entry_nome_autor.grid(row=0, column=1)

tk.Label(frame_autor, text='Nacionalidade:', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_nacionalidade_autor = tk.Entry(frame_autor, font=font_entry)
entry_nacionalidade_autor.grid(row=1, column=1)

tk.Button(frame_autor, text='Adicionar Autor', command=add_autor, font=font_label).grid(row=2, columnspan=2, pady=5)

# Frame para adicionar livro
frame_livro = tk.LabelFrame(root, text='Adicionar Livro', bg='lightblue', font=('Arial', 14))
frame_livro.grid(row=0, column=1, padx=10, pady=10, sticky='nsew')

tk.Label(frame_livro, text='Título:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_titulo_livro = tk.Entry(frame_livro, font=font_entry)
entry_titulo_livro.grid(row=0, column=1)

tk.Label(frame_livro, text='AutorID:', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_autor_id = tk.Entry(frame_livro, font=font_entry)
entry_autor_id.grid(row=1, column=1)

tk.Label(frame_livro, text='Ano de Publicação:', bg='lightblue', font=font_label).grid(row=2, column=0)
entry_ano_livro = tk.Entry(frame_livro, font=font_entry)
entry_ano_livro.grid(row=2, column=1)

tk.Label(frame_livro, text='Gênero:', bg='lightblue', font=font_label).grid(row=3, column=0)
entry_genero_livro = tk.Entry(frame_livro, font=font_entry)
entry_genero_livro.grid(row=3, column=1)

tk.Button(frame_livro, text='Adicionar Livro', command=add_livro, font=font_label).grid(row=4, columnspan=2, pady=5)

# Frame para adicionar empréstimo
frame_emprestimo = tk.LabelFrame(root, text='Adicionar Empréstimo', bg='lightblue', font=('Arial', 14))
frame_emprestimo.grid(row=1, column=0, padx=10, pady=10, sticky='nsew')

tk.Label(frame_emprestimo, text='LivroID:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_livro_id = tk.Entry(frame_emprestimo, font=font_entry)
entry_livro_id.grid(row=0, column=1)

tk.Label(frame_emprestimo, text='Data de Empréstimo (YYYY-MM-DD):', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_data_emp = tk.Entry(frame_emprestimo, font=font_entry)
entry_data_emp.grid(row=1, column=1)

tk.Label(frame_emprestimo, text='Data de Devolução (YYYY-MM-DD):', bg='lightblue', font=font_label).grid(row=2, column=0)
entry_data_dev = tk.Entry(frame_emprestimo, font=font_entry)
entry_data_dev.grid(row=2, column=1)

tk.Label(frame_emprestimo, text='Nome do Usuário:', bg='lightblue', font=font_label).grid(row=3, column=0)
entry_nome_usuario = tk.Entry(frame_emprestimo, font=font_entry)
entry_nome_usuario.grid(row=3, column=1)

tk.Button(frame_emprestimo, text='Adicionar Empréstimo', command=add_emprestimo, font=font_label).grid(row=4, columnspan=2, pady=5)

# Frame para adicionar usuário
frame_usuario = tk.LabelFrame(root, text='Adicionar Usuário', bg='lightblue', font=('Arial', 14))
frame_usuario.grid(row=1, column=1, padx=10, pady=10, sticky='nsew')

tk.Label(frame_usuario, text='Nome:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_nome_usuario_adicionar = tk.Entry(frame_usuario, font=font_entry)
entry_nome_usuario_adicionar.grid(row=0, column=1)

tk.Label(frame_usuario, text='Email:', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_email_usuario = tk.Entry(frame_usuario, font=font_entry)
entry_email_usuario.grid(row=1, column=1)

tk.Button(frame_usuario, text='Adicionar Usuário', command=add_usuario, font=font_label).grid(row=2, columnspan=2, pady=5)

# Frame para visualizar usuários
frame_visualizar_usuarios = tk.LabelFrame(root, text='Visualizar Usuários', bg='lightblue', font=('Arial', 14))
frame_visualizar_usuarios.grid(row=2, column=0, padx=10, pady=10, sticky='nsew')

tk.Button(frame_visualizar_usuarios, text='Ver Todos os Usuários', command=view_usuarios, font=font_label).grid(row=0, columnspan=2)

tk.Label(frame_visualizar_usuarios, text='Nome ou Email:', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_usuario_especifico = tk.Entry(frame_visualizar_usuarios, font=font_entry)
entry_usuario_especifico.grid(row=1, column=1)

tk.Button(frame_visualizar_usuarios, text='Ver Usuário Específico', command=view_usuario_especifico, font=font_label).grid(row=2, columnspan=2)

# Lista para mostrar usuários
usuarios_list = tk.Listbox(frame_visualizar_usuarios, height=10, width=50, font=font_entry)
usuarios_list.grid(row=3, column=0, columnspan=2)

# Frame para visualizar empréstimos
frame_emprestimos_usuario = tk.LabelFrame(root, text='Visualizar Empréstimos', bg='lightblue', font=('Arial', 14))
frame_emprestimos_usuario.grid(row=2, column=1, padx=10, pady=10, sticky='nsew')

tk.Button(frame_emprestimos_usuario, text='Ver Meus Empréstimos', command=view_emprestimos_usuario, font=font_label).grid(row=0, columnspan=2)

tk.Label(frame_emprestimos_usuario, text='Usuário:', bg='lightblue', font=font_label).grid(row=1, column=0)
entry_usuario_emprestimos = tk.Entry(frame_emprestimos_usuario, font=font_entry)
entry_usuario_emprestimos.grid(row=1, column=1)

# Lista para mostrar os empréstimos
emprestimos_list = tk.Listbox(frame_emprestimos_usuario, height=10, width=50, font=font_entry)
emprestimos_list.grid(row=2, column=0, columnspan=2)

# Frame para buscar livros por gênero
frame_busca_genero = tk.LabelFrame(root, text='Buscar Livros por Gênero', bg='lightblue', font=('Arial', 14))
frame_busca_genero.grid(row=3, column=0, padx=10, pady=10, sticky='nsew')

tk.Label(frame_busca_genero, text='Gênero:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_genero_busca = tk.Entry(frame_busca_genero, font=font_entry)
entry_genero_busca.grid(row=0, column=1)

tk.Button(frame_busca_genero, text='Ver Livros', command=view_livros_genero, font=font_label).grid(row=1, columnspan=2)

# Lista para mostrar livros de um gênero
livros_list = tk.Listbox(frame_busca_genero, height=10, width=50, font=font_entry)
livros_list.grid(row=2, column=0, columnspan=2)

# Frame para buscar livros
frame_busca_livro = tk.LabelFrame(root, text='Buscar Livro', bg='lightblue', font=('Arial', 14))
frame_busca_livro.grid(row=3, column=1, padx=10, pady=10, sticky='nsew')

tk.Label(frame_busca_livro, text='Título ou Palavra:', bg='lightblue', font=font_label).grid(row=0, column=0)
entry_busca_livro = tk.Entry(frame_busca_livro, font=font_entry)
entry_busca_livro.grid(row=0, column=1)

tk.Button(frame_busca_livro, text='Buscar', command=search_livro, font=font_label).grid(row=1, columnspan=2)

# Lista para mostrar resultados da busca
search_result_list = tk.Listbox(frame_busca_livro, height=10, width=50, font=font_entry)
search_result_list.grid(row=2, column=0, columnspan=2)

# Configuração do grid para expandir com a janela
for i in range(4):  # Para as quatro linhas de frames
    root.grid_rowconfigure(i, weight=1)

for i in range(2):  # Para as duas colunas de frames
    root.grid_columnconfigure(i, weight=1)

root.mainloop()

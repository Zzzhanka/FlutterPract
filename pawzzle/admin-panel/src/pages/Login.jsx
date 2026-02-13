import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const navigate = useNavigate();

  const submit = (e) => {
    e.preventDefault();

    // Фейковая проверка
    if (email === "admin@mail.com" && password === "1234") {
      localStorage.setItem("token", "fake-jwt-token");
      navigate("/dashboard");
    } else {
      alert("Неверный логин или пароль");
    }
  };

  return (
    <div style={styles.container}>
      <form onSubmit={submit} style={styles.form}>
        <h2 style={{ marginBottom: 20 }}>Вход администратора</h2>

        <input
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={styles.input}
        />

        <input
          type="password"
          placeholder="Пароль"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={styles.input}
        />

        <button type="submit" style={styles.button}>
          Войти
        </button>
      </form>
    </div>
  );
}

const styles = {
  container: {
    height: "100vh", // на весь экран
    width: "100%", // чтобы растянуть по горизонтали
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    background: "#f4f6f9",
  },
  form: {
    background: "white",
    padding: 40,
    borderRadius: 10,
    boxShadow: "0 4px 20px rgba(0,0,0,0.1)",
    display: "flex",
    flexDirection: "column",
    width: 300,
    maxWidth: "90vw", // адаптация под маленькие экраны
  },
  input: {
    marginBottom: 15,
    padding: 10,
    fontSize: 14,
  },
  button: {
    padding: 10,
    background: "#4f46e5",
    color: "white",
    border: "none",
    cursor: "pointer",
  },
};

import { Link, useNavigate } from "react-router-dom";

export default function Navbar() {
  const navigate = useNavigate();

  const logout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  return (
    <nav style={{ padding: 20, background: "#eee" }}>
      <Link to="/">Главная</Link> |{" "}
      <Link to="/users">Пользователи</Link> |{" "}
      <Link to="/levels">Уровни</Link>
      <button style={{ float: "right" }} onClick={logout}>Выйти</button>
    </nav>
  );
}

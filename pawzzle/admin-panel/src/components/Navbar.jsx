import { NavLink } from "react-router-dom";

export default function Navbar() {
  const linkStyle = ({ isActive }) => ({
    display: "block",
    padding: "12px 20px",
    margin: "8px 0",
    textDecoration: "none",
    color: isActive ? "#fff" : "#333",
    backgroundColor: isActive ? "#4a90e2" : "transparent",
    borderRadius: 8,
    transition: "0.2s",
  });

  return (
    <aside
      style={{
        width: 220,
        padding: 20,
        backgroundColor: "#fff",
        borderRight: "1px solid #ddd",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <h2 style={{ marginBottom: 20, color: "#4a90e2" }}>Admin Panel</h2>
      <NavLink to="/dashboard" style={linkStyle}>Dashboard</NavLink>
      <NavLink to="/users" style={linkStyle}>Users</NavLink>
      <NavLink to="/levels" style={linkStyle}>Levels</NavLink>
      <NavLink to="/daily" style={linkStyle}>Daily</NavLink>
    </aside>
  );
}
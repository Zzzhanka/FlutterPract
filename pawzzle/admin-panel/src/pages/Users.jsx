import { useEffect, useState } from "react";
import api from "../api/api";

export default function Users() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    api.get("/users").then((res) => setUsers(res.data));
  }, []);

  const blockUser = async (id) => {
    await api.put(`/users/${id}/block`);
    setUsers(users.map(u =>
      u.id === id ? { ...u, is_blocked: !u.is_blocked } : u
    ));
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Пользователи</h2>
      <table border="1" cellPadding="8">
        <thead>
          <tr>
            <th>Email</th>
            <th>Роль</th>
            <th>Статус</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {users.map(u => (
            <tr key={u.id}>
              <td>{u.email}</td>
              <td>{u.role}</td>
              <td>{u.is_blocked ? "Заблокирован" : "Активен"}</td>
              <td>
                <button onClick={() => blockUser(u.id)}>
                  {u.is_blocked ? "Разблокировать" : "Заблокировать"}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

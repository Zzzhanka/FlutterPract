import { useEffect, useState } from "react";
import api from "../api/api";

export default function Levels() {
  const [levels, setLevels] = useState([]);

  useEffect(() => {
    api.get("/levels").then(res => setLevels(res.data));
  }, []);

  const togglePublish = async (id) => {
    await api.put(`/levels/${id}/toggle`);
    setLevels(levels.map(l =>
      l.id === id ? { ...l, is_published: !l.is_published } : l
    ));
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Уровни</h2>
      <table border="1" cellPadding="8">
        <thead>
          <tr>
            <th>ID</th>
            <th>Название</th>
            <th>Сетка</th>
            <th>Статус</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {levels.map(l => (
            <tr key={l.id}>
              <td>{l.id}</td>
              <td>{l.title}</td>
              <td>{l.grid_size}x{l.grid_size}</td>
              <td>{l.is_published ? "Опубликован" : "Скрыт"}</td>
              <td>
                <button onClick={() => togglePublish(l.id)}>
                  Переключить
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

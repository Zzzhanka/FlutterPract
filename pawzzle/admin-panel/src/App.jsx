import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Login from "./pages/Login";
import Users from "./pages/Users";
import Levels from "./pages/Levels";
import ProtectedRoute from "./components/ProtectedRoute";
import Navbar from "./components/Navbar";
import Daily from "./pages/Daily";


function Dashboard() {
  return <div>Добро пожаловать в админ-панель</div>;
}

// Общий layout для защищенных страниц
function AdminLayout({ children }) {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        minHeight: "100vh",
        width: "100%",
      }}
    >
      <Navbar />
      <main
        style={{
          flex: 1,
          width: "100%",
          maxWidth: 1200, // максимум ширины контента
          margin: "0 auto", // центрирование
          padding: 20,
          boxSizing: "border-box",
        }}
      >
        {children}
      </main>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" />} />
        <Route path="/login" element={<Login />} />

        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <AdminLayout>
                <Dashboard />
              </AdminLayout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/users"
          element={
            <ProtectedRoute>
              <AdminLayout>
                <Users />
              </AdminLayout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/levels"
          element={
            <ProtectedRoute>
              <AdminLayout>
                <Levels />
              </AdminLayout>
            </ProtectedRoute>
          }
        />

        <Route
          path="/daily"
          element={
            <ProtectedRoute>
              <AdminLayout>
                <Daily />
              </AdminLayout>
            </ProtectedRoute>
          }
        />

      </Routes>
    </BrowserRouter>
  );
}

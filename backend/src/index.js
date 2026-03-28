import app from "./app.js";
import dotenv from "dotenv";

dotenv.config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`\n🚀 Monad Ticket Backend Server Running`);
  console.log(`📍 Server: http://localhost:${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || "development"}`);
  console.log(`\n✅ Ready to handle requests\n`);
});

export const errorHandler = (err, req, res, next) => {
  console.error("Error:", err);

  if (err.name === "ValidationError") {
    return res.status(400).json({
      error: "Validation failed",
      details: err.message,
    });
  }

  if (err.name === "JsonWebTokenError") {
    return res.status(401).json({
      error: "Invalid token",
    });
  }

  if (err.code === "CONTRACT_CALL_EXCEPTION") {
    return res.status(400).json({
      error: "Smart contract call failed",
      details: err.reason || err.message,
    });
  }

  res.status(500).json({
    error: "Internal server error",
    details: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
};

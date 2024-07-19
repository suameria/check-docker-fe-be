export async function fetchTestAPI() {
  const res = await fetch("http://localhost:8080/api/test");
  const data = await res.json();
  return data;
}

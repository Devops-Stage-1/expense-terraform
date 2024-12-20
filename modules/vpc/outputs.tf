output "vpc" {
  value = aws_vpc.main.id
}

output "frontend" {
  value = aws_subnet.frontend.*.id
}

output "backend" {
  value = aws_subnet.backend.*.id
}

output "db" {
  value = aws_subnet.db.*.id
}

output "public" {
  value = aws_subnet.public.*.id
}
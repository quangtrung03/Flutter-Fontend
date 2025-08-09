import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFFF7F7F7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Row(
            children: const [
              SizedBox(width: 16),
              Icon(Icons.show_chart, size: 28, color: Colors.black87),
              SizedBox(width: 8),
              Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 32),
          _SidebarItem(icon: Icons.dashboard, label: 'Dashboard'),
          _SidebarItem(icon: Icons.shopping_bag, label: 'Products'),
          _SidebarItem(icon: Icons.receipt_long, label: 'Orders'),
          _SidebarItem(icon: Icons.image, label: 'Banner'),
          _SidebarItem(icon: Icons.person, label: 'User'),
          _SidebarItem(icon: Icons.article, label: 'Blog'),
          _SidebarItem(icon: Icons.support_agent, label: 'support customers'),
          _SidebarItem(icon: Icons.chat, label: 'Chat'),
          _SidebarItem(icon: Icons.card_giftcard, label: 'Vouchers'),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:do_an_mobile_nc/admin/models/admin_blog_model.dart';
import 'package:do_an_mobile_nc/admin/services/admin_blog_service.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  List<Blog> blogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    setState(() { isLoading = true; });
    try {
      blogs = await AdminBlogService.getAllBlogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải blog: $e')),
      );
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay về Dashboard',
        ),
        title: const Text(
          "Quản Lý Blog",
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showBlogForm(),
              icon: const Icon(Icons.add),
              label: const Text("Thêm bài viết mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : constraints.maxWidth > 900
                          ? 3
                          : constraints.maxWidth > 600
                              ? 2
                              : 1;
                  return GridView.builder(
                    itemCount: blogs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final blog = blogs[index];
                      return _buildBlogCard(blog, context);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildBlogCard(Blog blog, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              blog.image,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blog.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  _formatDate(blog.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Text(blog.content, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _showBlogForm(blog: blog),
                      child: const Text("Sửa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _deleteBlog(blog),
                      child: const Text("Xoá"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(60, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBlogForm({Blog? blog}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BlogForm(
        blog: blog,
      ),
    );
    if (result == true) fetchBlogs();
  }

  void _deleteBlog(Blog blog) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá blog "${blog.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await AdminBlogService.deleteBlog(blog.id);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xoá blog!')));
      fetchBlogs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xoá thất bại!')));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class BlogForm extends StatefulWidget {
  final Blog? blog;
  const BlogForm({Key? key, this.blog}) : super(key: key);

  @override
  State<BlogForm> createState() => _BlogFormState();
}

class _BlogFormState extends State<BlogForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController imageController;
  late TextEditingController dateController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.blog?.title ?? '');
    contentController = TextEditingController(text: widget.blog?.content ?? '');
    imageController = TextEditingController(text: widget.blog?.image ?? '');
    dateController = TextEditingController(text: widget.blog != null ? _formatDate(widget.blog!.date) : '');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? _parseDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; });
    DateTime? date;
    if (dateController.text.isNotEmpty) {
      date = _parseDate(dateController.text);
      if (date == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ngày không hợp lệ. Định dạng: dd/mm/yyyy')));
        setState(() { isLoading = false; });
        return;
      }
    }
    final blog = Blog(
      id: widget.blog?.id ?? '',
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      image: imageController.text.trim(),
      slug: '',
      date: date ?? DateTime.now(),
      createdAt: widget.blog?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    bool ok = false;
    if (widget.blog == null) {
      ok = await AdminBlogService.createBlog(blog);
    } else {
      ok = await AdminBlogService.updateBlog(widget.blog!.id, blog);
    }
    setState(() { isLoading = false; });
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.blog == null ? 'Đã tạo blog!' : 'Đã cập nhật blog!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thao tác thất bại!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.blog == null ? 'Thêm Blog' : 'Sửa Blog',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Nội dung'),
                  minLines: 3,
                  maxLines: 6,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Link ảnh'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Ngày đăng (dd/mm/yyyy)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.blog == null ? 'Tạo mới' : 'Cập nhật'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

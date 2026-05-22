import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  final VoidCallback? onClose;

  const ChatView({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          // Sidebar width
          final sidebarWidth = screenWidth < 400 ? 160.0 : 162.0;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contacts sidebar
              Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(right: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    // Sidebar header with "Chat" text
                    Container(
                      width: sidebarWidth,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Chat'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                onPressed: controller.loadContacts,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              ),
                              if (onClose != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: onClose,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Contacts list with custom rows for better alignment
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (controller.contacts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('No contacts'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: controller.contacts.length,
                          itemBuilder: (context, index) {
                            final contact = controller.contacts[index];
                            final isSelected = controller.selectedContact.value?.userId == contact.userId;
                            return InkWell(
                              onTap: () => controller.selectContact(contact),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue[50] : Colors.transparent,
                                  border: isSelected ? null : Border(
                                    bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        contact.fullName.isNotEmpty
                                            ? contact.fullName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            contact.fullName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            contact.role,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Chat area
              Expanded(
                child: Obx(() {
                  if (controller.selectedContact.value == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text('Select a contact'.tr, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      // Chat header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue,
                              child: Text(
                                controller.selectedContact.value!.fullName[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    controller.selectedContact.value!.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  // Connection status
                                  Obx(
                                        () => Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: controller.isWsConnected.value
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          controller.isWsConnected.value
                                              ? 'Connected'.tr
                                              : controller.connectionStatus.value.isNotEmpty
                                              ? controller.connectionStatus.value
                                              : 'Connecting...'.tr,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: controller.isWsConnected.value
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 18),
                              onPressed: () {
                                if (controller.selectedContact.value != null) {
                                  controller.loadMessages(controller.selectedContact.value!.userId);
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),
                      // Messages list
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Obx(
                                () => ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) {
                                final msg = controller.messages[index];
                                final isOwn = controller.isOwnMessage(msg);
                                return Align(
                                  alignment: isOwn
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                                      minWidth: 60,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOwn ? Colors.blue : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          msg.content,
                                          softWrap: true,
                                          style: TextStyle(
                                            color: isOwn ? Colors.white : Colors.black87,
                                            fontSize: 14,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          controller.formatTime(msg.createdAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isOwn ? Colors.white70 : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Input area
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type a message...'.tr,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: controller.updateNewMessage,
                                onSubmitted: (_) => controller.sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Obx(
                                  () => ElevatedButton(
                                onPressed: controller.isSending.value ||
                                    controller.newMessage.value.isEmpty
                                    ? null
                                    : controller.sendMessage,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(10),
                                  minimumSize: const Size(40, 40),
                                ),
                                child: const Icon(Icons.send, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
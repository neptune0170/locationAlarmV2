import 'package:flutter/material.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/BubblesBackground.JPG'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50.0,
                left: 5.0,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 100),
                child: Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors
                .grey, // You can set a different color for unselected tabs if needed
            indicatorColor: Colors.black,
            labelStyle: const TextStyle(
              fontSize:
                  15, // Set the font size of the selected tab label to 20 pixels
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize:
                  15, // Set the font size of the unselected tab labels to 20 pixels
            ),
            tabs: [
              Tab(text: 'Account Data'),
              Tab(text: 'Personal'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAccountDataTab(),
                _buildPersonalTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDataTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email address',
              labelStyle: TextStyle(
                color: Colors.grey, // Set the label text color to grey
                fontWeight: FontWeight.w500,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // Set the underline color to grey
                  width: 0.5, // Set the underline width to 0.5
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors
                      .black, // Set the underline color to grey when focused
                  width: 0.5, // Set the underline width to 0.5 when focused
                ),
              ),
            ),
          ),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                // Set the label text color to grey
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // Set the underline color to grey
                  width: 0.5, // Set the underline width to 0.5
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors
                      .black, // Set the underline color to grey when focused
                  width: 0.5, // Set the underline width to 0.5 when focused
                ),
              ),
              suffixIcon: Icon(Icons.visibility_off),
            ),
          ),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete account',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Your account will be permanently removed from the application. All your data will be lost.',
                style: TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Handle delete account action
            },
            style: ElevatedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                backgroundColor: Color(0xFFFFF3F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 60),
                elevation: 0,
                shadowColor: Colors.transparent),
            child: Text(
              'Delete account',
              style: TextStyle(fontSize: 17),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 0, left: 0, bottom: 15),
            child: Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save action
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(double.infinity, 60),
            ),
            child: Text(
              'Save',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'First Name',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Last Name',
              labelStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arrive On time Score (AOT)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Light grey background color
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  '93.5',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'What is ',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                'AOT Score ',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                'and how it is calculated ?',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w300),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 0, left: 0, bottom: 15),
            child: Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 0, left: 0, bottom: 15),
            child: Divider(
              height: 0.0,
              thickness: 0.5,
              color: Colors.grey,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save action
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: Size(double.infinity, 60),
            ),
            child: Text(
              'Save',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

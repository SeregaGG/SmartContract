
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList {

    uint8 public firstKey;
    uint8 public lastTaskKey;
    uint8 public keyStep;


    struct task {
        string taskName;
        uint32 taskStartTime;
        bool isCompleted;
    }


    mapping(uint8 => task) tasks;


    constructor() public {

        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        firstKey = 0;
        lastTaskKey = firstKey;
        keyStep = 1;
    }


    modifier checkOwnerAndAccept {
		
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}


    function taskAdd(string name) public checkOwnerAndAccept {

        tasks[lastTaskKey] = task(name, now, false);
        lastTaskKey += keyStep;
    }


    function getCountCurrentTasks() public view checkOwnerAndAccept returns (uint256) {

        uint256 countCurrentTasks = 0;
        for (uint8 i = firstKey; i < lastTaskKey; i+=keyStep) {

            if(tasks.exists(i) && !tasks[i].isCompleted){
                
                countCurrentTasks++;
            }
        }

        return countCurrentTasks;
    }


    function getTaskList() public view checkOwnerAndAccept returns (string[]){

        string[] allTasks;

        for (uint8 i = firstKey; i < lastTaskKey; i+=keyStep) {
           
            if(tasks.exists(i)) {

                allTasks.push(tasks[i].taskName);
            }
        }

        return allTasks;
    }


    function getTaskDescriptionByKey(uint8 key) public view checkOwnerAndAccept returns(task){
        
        require(tasks.exists(key), 101);

        return tasks[key];
    }

    function deleteTaskByKey(uint8 key) public checkOwnerAndAccept {
        
        require(tasks.exists(key), 101);
        
        delete tasks[key];
    }

    function setTaskCompleteByKey(uint8 key) public checkOwnerAndAccept {
        
        require(tasks.exists(key), 101);
        tasks[key].isCompleted = true;
    }

}

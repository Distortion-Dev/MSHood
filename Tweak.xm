@interface SBTelephonyManager : NSObject {}
	+ (id)sharedTelephonyManager;
	- (BOOL)isInAirplaneMode;
	- (void)setIsInAirplaneMode:(BOOL)state;
@end
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach_traps.h>
#include <mach/mach_init.h>
#import <UIKit/UIKit.h>
#import <unistd.h>
#import <objc/runtime.h>
#import <objc/objc.h>
#import <stdio.h>
#import <string.h>

#import <mach/mach_host.h>
#import <sys/sysctl.h>

#include <CoreFoundation/CoreFoundation.h>


#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

static UIWindow *mainWindow = nil;

static UIButton *airport = nil;
static UIButton *blueToothButton = nil;
static UIButton *edgeButton = nil;
static UIButton *respring = nil;
static UIView *everything = nil;
static UIButton *myButton = nil;
static UIButton *process = nil;
static UILabel *usedLabel = nil;
static UILabel *freeLabel = nil;
static UILabel *activeLabel = nil;
static UILabel *inactiveLabel = nil;
static UILabel *wiredLabel = nil;
#include <libactivator/libactivator.h>
@interface Hood : NSObject <LAListener> {
	vm_statistics_data_t	mVMStat;
	vm_size_t 		mPageSize;
	mach_port_t		mHost;
	vm_size_t		mTotalPages;
}
- (void)setUpAirplaneToggle;
- (void)setUpRespringToggle;
- (void)setUpBlueToothToggle;
- (void)setUpEdgeToggle;
- (void)setUpStatistics;
- (void)updateLabel:(UILabel *)label withPages:(natural_t)pages name:(NSString *)name;
- (NSString *)nameForProcessWithPID:(pid_t)pidNum;
- (NSString *)byteSizeDescription:(double)dBytes;
@end
@implementation Hood
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (mainWindow == nil) {
		mainWindow = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] retain];
		mainWindow.windowLevel = 66666;
	}
	[mainWindow setAlpha:1];
	[mainWindow setHidden:NO];

	[mainWindow setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
	if (myButton == nil) {
		myButton = [UIButton buttonWithType:UIButtonTypeCustom];
	}
	[myButton retain];
	[myButton setFrame:CGRectMake(0,0,320,480)];
	[myButton addTarget:nil action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
	[mainWindow addSubview:myButton];
	if (everything == nil) {
		everything = [[[UIView alloc] initWithFrame:CGRectMake(0,20,320,240)] retain];
	}
	[everything setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"HoodWallpaper"]]];
	[mainWindow addSubview:everything];
	[self setUpAirplaneToggle];
	[self setUpRespringToggle];
	[self setUpBlueToothToggle];
	[self setUpEdgeToggle];
	[self setUpStatistics];

	if (process == nil) {
		process = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	[process setFrame:CGRectMake(0,216,320,24)];
	[process setImage:[UIImage imageNamed:@"RipHoodSlidingDisclosure"] forState:UIControlStateNormal];
	[everything addSubview:process];

}

- (void)setUpAirplaneToggle {
	if (airport == nil) {
		airport = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	[airport setFrame:CGRectMake(20,15,59,59)];
	BOOL ar = [(SBTelephonyManager *)[objc_getClass("SBTelephonyManager") sharedTelephonyManager] isInAirplaneMode];
	if (ar) {
		[airport setImage:[UIImage imageNamed:@"RipHoodAirportIcon"] forState:UIControlStateNormal];
	}
	else {
		[airport setImage:[UIImage imageNamed:@"RipHoodAirportIconOff"] forState:UIControlStateNormal];
	}	
	[airport addTarget:nil action:@selector(setAirplaneMode) forControlEvents:UIControlEventTouchUpInside];
	[everything addSubview:airport];
}
- (void)setUpRespringToggle {
	if (respring == nil) {
		respring = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	[respring setFrame:CGRectMake(245, 15, 59, 59)];
	[respring setImage:[UIImage imageNamed:@"RipHoodRespringIconOff"] forState:UIControlStateNormal];
	[respring addTarget:nil action:@selector(setRespringMode) forControlEvents:UIControlEventTouchUpInside];
	[everything addSubview:respring];
}
- (void)setUpBlueToothToggle {
	if (blueToothButton == nil) {
		blueToothButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	[blueToothButton setFrame:CGRectMake(95, 15, 59, 59)];
	[blueToothButton setImage:[UIImage imageNamed:@"RipHoodBluetoothIconOff"] forState:UIControlStateNormal];
	[blueToothButton addTarget:nil action:@selector(setBluetoothMode) forControlEvents:UIControlEventTouchUpInside];
	[everything addSubview:blueToothButton];
}
- (void)setUpEdgeToggle {
	if (edgeButton == nil) {
		edgeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	[edgeButton setFrame:CGRectMake(170, 15, 59, 59)];
	[edgeButton setImage:[UIImage imageNamed:@"RipHoodEDGEIconOff"] forState:UIControlStateNormal];
	[edgeButton addTarget:nil action:@selector(setEdgeMode) forControlEvents:UIControlEventTouchUpInside];
	[everything addSubview:edgeButton];
// testtt
	NSMutableArray *processes = [[NSMutableArray alloc] initWithObjects:@"ff", @"fds", nil];
	[processes removeAllObjects];
	NSMutableDictionary *pidInfo = [[NSMutableDictionary alloc] init];

	int name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
	int res;
	size_t sz = 0;
	
	res = sysctl(name, (sizeof(name)/sizeof(int)), NULL, &sz, NULL, 0);
	if (0 == res && sz > 0)
	{
		struct kinfo_proc* pc = (struct kinfo_proc*)malloc(sz);
		
		if (pc)
		{
			res = sysctl(name, (sizeof(name)/sizeof(int)), (void*)pc, &sz, NULL, 0);
			int pcCount = sz / sizeof(struct kinfo_proc);
			int i;
			
			for (i=0; i < pcCount; i++)
			{
				NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
				NSNumber* pid = [NSNumber numberWithInt:pc[i].kp_proc.p_pid];
				
				if (![pidInfo objectForKey:pid])
				{				
					NSMutableDictionary* pinfo = [NSMutableDictionary dictionaryWithCapacity:0];
					NSString* processPath = [self nameForProcessWithPID:pc[i].kp_proc.p_pid];
					
					if (processPath)
					{
						[pinfo setObject:processPath forKey:@"path"];
						
						if ([[[processPath stringByDeletingLastPathComponent] pathExtension] isEqualToString:@"app"])
						{
							NSBundle* bundle = [NSBundle bundleWithPath:[processPath stringByDeletingLastPathComponent]];
							
							if (bundle)
							{
								NSString* bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
								
								[pinfo setObject:bundle forKey:@"bundle"];
								
								if (bundleName)
									[pinfo setObject:bundleName forKey:@"name"];
								else
									[pinfo setObject:[[[processPath stringByDeletingLastPathComponent] lastPathComponent] stringByDeletingPathExtension] forKey:@"name"];
							}
							else
								[pinfo setObject:[[[processPath stringByDeletingLastPathComponent] lastPathComponent] stringByDeletingPathExtension] forKey:@"name"];
						}
						else
						{
							[pinfo setObject:[processPath lastPathComponent] forKey:@"name"];
						}
					}
					else
						[pinfo setObject:[NSString stringWithUTF8String:pc[i].kp_proc.p_comm] forKey:@"name"];
					
					[pinfo setObject:pid forKey:@"pid"];
					
					[pinfo setObject:[NSNumber numberWithInt:pc[i].kp_eproc.e_pcred.p_ruid] forKey:@"gid"];
/*					[pinfo setObject:[NSNumber numberWithUnsignedInt:pc[i].kp_proc.p_swtime] forKey:@"swtime"];
					[pinfo setObject:[NSNumber numberWithUnsignedInt:pc[i].kp_proc.p_slptime] forKey:@"slptime"];
					[pinfo setObject:[NSNumber numberWithUnsignedInt:pc[i].kp_proc.p_estcpu] forKey:@"estcpu"];
					[pinfo setObject:[NSNumber numberWithUnsignedInt:pc[i].kp_proc.p_cpticks] forKey:@"cpticks"];
					[pinfo setObject:[NSNumber numberWithUnsignedInt:pc[i].kp_proc.p_pctcpu] forKey:@"pctcpu"]; */
					
					[pidInfo setObject:pinfo forKey:pid];
				}
				
				[processes addObject:pid];
				
				[pool release];
			}
			
			// TODO: implement cleanup of dead pids from pidInfo dictionary
			
			free(pc);
		}
	}
	


}
- (void)updateLabel:(UILabel *)label withPages:(natural_t)pages name:(NSString *)name {
	label.text = [NSString stringWithFormat:@"%@: %@", name, [self byteSizeDescription:pages]];
}

- (void)setUpStatistics {
	if (usedLabel == nil) {
		usedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170, 90, 137, 23)] retain];
	}
	usedLabel.textColor = [UIColor whiteColor];
	usedLabel.font = [UIFont systemFontOfSize:17];
	[usedLabel setBackgroundColor:[UIColor clearColor]];
	if (freeLabel == nil) {
		freeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170, 110, 137, 23)] retain];
	}
	freeLabel.textColor = [UIColor greenColor];
	[freeLabel setBackgroundColor:[UIColor clearColor]];
	freeLabel.font = [UIFont systemFontOfSize:17];
	if (activeLabel == nil) {
		activeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170, 130, 137, 23)] retain];
	}
	activeLabel.textColor = [UIColor redColor];
	activeLabel.font = [UIFont systemFontOfSize:17];
	[activeLabel setBackgroundColor:[UIColor clearColor]];
	if (inactiveLabel == nil) {
		inactiveLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170, 150, 137, 23)] retain];
	}
	inactiveLabel.textColor = [UIColor yellowColor];
	inactiveLabel.font = [UIFont systemFontOfSize:17];
	inactiveLabel.backgroundColor = [UIColor clearColor];
	if (wiredLabel == nil) {
		wiredLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170, 170, 137, 23)] retain];
	}
	wiredLabel.textColor = [UIColor cyanColor];
	wiredLabel.font = [UIFont systemFontOfSize:17];
	wiredLabel.backgroundColor = [UIColor clearColor];
	[everything addSubview:usedLabel];
	[everything addSubview:freeLabel];
	[everything addSubview:activeLabel];
	[everything addSubview:inactiveLabel];
	[everything addSubview:wiredLabel];




	size_t length;
	int mib[6]; 

	int pagesize;
	mib[0] = CTL_HW;
	mib[1] = HW_PAGESIZE;
	length = sizeof(pagesize);
	if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0) {
		perror("getting page size");
	}
	NSLog(@"Page size = %d bytes\n", pagesize);
	NSLog(@"\n");
	mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
	vm_statistics_data_t vmstat;
	if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS) {
		NSLog(@"Failed to get VM statistics.");
	}
 
	double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
	double wired = vmstat.wire_count / total;
	double active = vmstat.active_count / total;
	double inactive = vmstat.inactive_count / total;
	double free = vmstat.free_count / total;
	mHost = mach_host_self();
	if (host_page_size(mHost, &mPageSize) != KERN_SUCCESS)
		mPageSize = 4096;
		
	mTotalPages = 0;
	
	size_t bufSize = sizeof(mTotalPages);
	if (sysctlbyname("hw.physmem", &mTotalPages, &bufSize, NULL, 0) == 0)
	{
		mTotalPages /= mPageSize;
	}
	NSLog(@"Total =    %8d pages\n", vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count);
	NSLog(@"Wired =    %8d bytes\n", vmstat.wire_count * pagesize);
	NSLog(@"Wired = %@", [self byteSizeDescription:vmstat.wire_count * pagesize]);
	NSLog(@"Active =   %8d bytes\n", vmstat.active_count * pagesize);
	NSLog(@"Inactive = %8d bytes\n", vmstat.inactive_count * pagesize);
	NSLog(@"Free =     %8d bytes\n", vmstat.free_count * pagesize);
	NSLog(@"Total =    %8d bytes\n", (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize);
	NSLog(@"Wired =    %0.2f %%\n", wired * 100.0);
	NSLog(@"Active =   %0.2f %%\n", active * 100.0);
	NSLog(@"Inactive = %0.2f %%\n", inactive * 100.0);
	NSLog(@"Free =     %0.2f %%\n", free * 100.0);
	NSLog(@"Used =     %8d  %%\n", mTotalPages - vmstat.free_count);
	NSLog(@"0.0  %@", [self byteSizeDescription:vmstat.free_count*mPageSize]);
	
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
   
	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);    
 
	vm_statistics_data_t vm_stat;
             
	if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
	        NSLog(@"Failed to fetch vm statistics");
 
    /* Stats in bytes */ 
	natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
	natural_t mem_free = vm_stat.free_count * pagesize;
	natural_t mem_total = mem_used + mem_free;
	NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);


	[self updateLabel:usedLabel withPages:(mTotalPages - vm_stat.free_count)*10 name:@"Used"];
	[self updateLabel:freeLabel withPages: vm_stat.free_count*10 name:@"Free"];
	freeLabel.text = [NSString stringWithFormat:@"Free %@", [self byteSizeDescription:vmstat.free_count*mPageSize]];
	[self updateLabel:activeLabel withPages: vm_stat.active_count name:@"Active"];
	[self updateLabel:inactiveLabel withPages: vm_stat.inactive_count name:@"Inactive"];
	[self updateLabel:wiredLabel withPages: vm_stat.wire_count name:@"Wired"];
}

- (NSString *)nameForProcessWithPID:(pid_t)pidNum {
	NSString *returnString = nil;
	int mib[4], numArgs = 0;
	size_t size = 0;
	char *stringPtr = NULL;
	int res;
	static char* args = NULL;
	static int maxarg = 0;
	
	// Yes, we leak KERN_ARGMAX number of bytes here, at the optimization of not calling malloc/free all the time.
	if (!args) {
		mib[0] = CTL_KERN;
		mib[1] = KERN_ARGMAX;
		
		size = sizeof(maxarg);
		if ( sysctl(mib, 2, &maxarg, &size, NULL, 0) == -1 ) {
			return nil;
		}
		
		args = (char *)malloc(maxarg);
		if (args == NULL) {
			return nil;
		}
	}
    
	mib[0] = CTL_KERN;
	mib[1] = KERN_PROCARGS2;
	mib[2] = pidNum;
    
	size = (size_t)maxarg;
	res = sysctl(mib, 3, args, &size, NULL, 0);
	if ( res == -1 ) {
		// no permission
		return nil;
	}
    
	memcpy( &numArgs, args, sizeof(numArgs) );
	stringPtr = args + sizeof(numArgs);
    
	returnString = [[NSString alloc] initWithUTF8String:stringPtr];
   
	return [returnString autorelease];
}

- (NSString *)byteSizeDescription:(double)dBytes {

	if(dBytes == 0) {
		return @"0 bytes";
	} else if(dBytes <= pow(2, 10)) {
		return [NSString stringWithFormat:@"%0.0f bytes", dBytes];
	} else if(dBytes <= pow(2, 20)) {
		return [NSString stringWithFormat:@"%0.1f KB", dBytes / pow(1024, 1)];
	} else if(dBytes <= pow(2, 30)) {
		return [NSString stringWithFormat:@"%0.1f MB", dBytes / pow(1024, 2)];
	} else if(dBytes <= pow(2, 40)) {
		return [NSString stringWithFormat:@"%0.1f GB", dBytes / pow(1024, 3)];
	} else {
		return [NSString stringWithFormat:@"%0.1f TB", dBytes / pow(1024, 4)];
	}
	return @"0.0 Error";
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {

}

+ (void)load {
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"Hood"];
}
@end
@interface BluetoothManager : NSObject
+ (id)sharedInstance;
- (BOOL)powered;
- (void)setPowered:(BOOL)powered;
@end
%hook SpringBoard

%new(v@:)
- (void)setAirplaneMode {
	id ct = [%c(SBTelephonyManager) sharedTelephonyManager];
	BOOL ar = [(SBTelephonyManager *)ct isInAirplaneMode];
	[(SBTelephonyManager *)ct setIsInAirplaneMode:!ar];
	if (ar) {
		[airport setImage:[UIImage imageNamed:@"RipHoodAirportIcon"] forState:UIControlStateNormal];
	}
	else {
		[airport setImage:[UIImage imageNamed:@"RipHoodAirportIconOff"] forState:UIControlStateNormal];
	}
}
%new(v@:)
- (void)setRespringMode {
	NSLog(@"Received respiring request");
}
%new(v@:)
- (void)setBluetoothMode {
	id ct = [%c(BluetoothManager) sharedInstance];
	BOOL ar = [(BluetoothManager *)ct powered];
	[(BluetoothManager *)ct setPowered:!ar];
	if (ar) {
		[blueToothButton setImage:[UIImage imageNamed:@"RipHoodBluetoothIconOff"] forState:UIControlStateNormal];
	}
	else {
		[blueToothButton setImage:[UIImage imageNamed:@"RipHoodBluetoothIcon"] forState:UIControlStateNormal];
	}
}
%new(v@:)
- (void)setEdgeMode {
	NSLog(@"Received Edge request");
}
%new(v@:)
- (void)removeView {

	if (mainWindow) {
		[mainWindow setAlpha:0];
		[mainWindow setHidden:YES];
	}


}

%end